USE MSPayment;

CREATE TABLE status_payment_enum (
  id INT auto_increment PRIMARY KEY,
  status_payment VARCHAR(100) NOT NULL
);

-- Esta tabela armazena os diferentes métodos possíveis para o pagamento.
CREATE TABLE payment_method_enum (
  id INT auto_increment PRIMARY KEY,
  payment_method VARCHAR(100) NOT NULL
);

-- Esta tabela armazena informações do pagamento do pedido
CREATE TABLE order_payment (
  id INT auto_increment PRIMARY KEY,
  last_update DATETIME NOT NULL,
  order_id INT NOT NULL,
  status_payment_enum_id INT NOT NULL,
  FOREIGN KEY (status_payment_enum_id) REFERENCES status_payment_enum(id),
  payment_method_enum_id INT NOT NULL,
  FOREIGN KEY (payment_method_enum_id) REFERENCES payment_method_enum(id)
);

-- Definindo a codificação de caracteres para UTF-8
SET character_set_client = utf8;
SET character_set_connection = utf8;
SET character_set_results = utf8;
SET collation_connection = utf8_general_ci;

-- CADASTRANDO OS STATUS DE PAGAMENTO
INSERT INTO status_payment_enum (status_payment) VALUES ('Aprovado');
INSERT INTO status_payment_enum (status_payment) VALUES ('Reprovado');

-- CADASTRANDO AS FORMAS DE PAGAMENTO
INSERT INTO payment_method_enum (payment_method) VALUES ('QrCode');
INSERT INTO payment_method_enum (payment_method) VALUES ('Dinheiro');
INSERT INTO payment_method_enum (payment_method) VALUES ('Crédito');
INSERT INTO payment_method_enum (payment_method) VALUES ('Débito');

-- CADASTRANDO UM PAGAMENTO DE PEDIDO
INSERT INTO order_payment (last_update, order_id, status_payment_enum_id, payment_method_enum_id) VALUES (now(), 12345, 1, 1)