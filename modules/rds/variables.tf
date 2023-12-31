variable "prefix" {
  description = "The prefix"
}

variable "subnet_ids" {
  type    = list(string)
  description = "Subnet ids"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "allocated_storage" {
  default     = "20"
  description = "The storage size in GB"
}

variable "instance_class" {
  description = "The instance type"
}

variable "multi_az" {
  default     = false
  description = "Muti-az allowed?"
}

variable "database_name" {
  description = "The database name"
}

variable "database_username" {
  description = "The username of the database"
}

variable "database_password" {
  description = "The password of the database"
}
