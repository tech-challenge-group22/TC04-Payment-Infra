
provider "aws" {
 region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "tfstate-tcfiap-payment"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

resource "aws_vpc" "payment_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "payment_gateway_vpc" {
  vpc_id = aws_vpc.payment_vpc.id
  tags = {
    Name = "payment-gateway-vpc"
  }
}

resource "aws_route_table" "payment_route_table" {
  vpc_id = aws_vpc.payment_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.payment_gateway_vpc.id
  }
  tags = {
    Name = "payment_route_table"
  }
}
resource "aws_subnet" "payment_public_subnet_a" {
  vpc_id = aws_vpc.payment_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "payment_public_subnet_b" {
  vpc_id = aws_vpc.payment_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "payment_subnet_association" {
  subnet_id     = aws_subnet.payment_public_subnet_a.id
  route_table_id = aws_route_table.payment_route_table.id
}

resource "aws_route_table_association" "payment_subnet_association_b" {
  subnet_id     = aws_subnet.payment_public_subnet_b.id
  route_table_id = aws_route_table.payment_route_table.id
}

resource "aws_subnet" "payment_private_subnet_a" {
  vpc_id = aws_vpc.payment_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "payment_private_subnet_b" {
  vpc_id = aws_vpc.payment_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "payment_inbound_security_group" {
  name        = "payment_inbound_security_group"
  description = "Security Group"
  vpc_id = aws_vpc.payment_vpc.id

  ingress {
    from_port   = 0
    to_port     = 8080
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "payment_database_security_group" {
  name = "Payment database secutiry group"
  description = "enable mysql/aurora"
  vpc_id = aws_vpc.payment_vpc.id
   ingress {
    description = "mysql/aurora access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.payment_inbound_security_group.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name ="payment database security group"
  }
}

resource "aws_db_instance" "db_postech_rds" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  publicly_accessible = true
  identifier = "payment-rds"
  username = var.db_username
  password =  var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.payment_database_security_group.id]
  db_name = "MSPayment"
  
}

resource "aws_db_subnet_group" "db_subnet" {
    name = "payment-dbsubnet"
    subnet_ids = [ aws_subnet.payment_public_subnet_a.id , aws_subnet.payment_public_subnet_b.id ]
  
}

resource "null_resource" "setup_db" {
  depends_on = [aws_db_instance.db_postech_rds]
  triggers = {
    instance_id = aws_db_instance.db_postech_rds.id
  }

  provisioner "local-exec" {
      command = "mysql -u${aws_db_instance.db_postech_rds.username} -p${aws_db_instance.db_postech_rds.password} -h${aws_db_instance.db_postech_rds.address} -P${aws_db_instance.db_postech_rds.port} < script-rds.sql"
   }
}
