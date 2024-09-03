# Singapore RDS 
resource "aws_db_instance" "sg_rds" {
  provider             = aws.ap-southeast-1  
  allocated_storage    = var.rds_storage
  db_name              = var.rds_name
  engine               = "postgres"
  engine_version       = var.rds_engine_version
  instance_class       = var.rds_instance_size
  username             = var.rds_username
  password             = data.aws_secretsmanager_secret_version.sg_postgres_db_password.secret_string
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.sg_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_rds_sg.id]
}

resource "aws_security_group" "sg_rds_sg" {
  provider    = aws.ap-southeast-1
  name        = "sg-rds-sg"
  description = "Security group for SG RDS"
  vpc_id      = aws_vpc.sg_vpc.id

  ingress {
    description      = "RDS from private subnet"
    from_port        = var.rds_port
    to_port          = var.rds_port
    protocol         = "tcp"
    cidr_blocks     = [var.tier_2_a_cidr,var.tier_2_b_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "sg_db_subnet_group" {
  name       = "sg_db_subnet_group"
  subnet_ids = [aws_subnet.sg_tier_2_a.id,aws_subnet.sg_tier_2_b.id]

  tags = {
    Environment = var.environment
  }
}

resource "random_password" "sg_postgres_db_password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "sg_postgres_db_password" {
  provider             = aws.ap-southeast-1  
  name = "sg-db-password"
  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "sg_postgres_db_password" {
  provider  = aws.ap-southeast-1  
  secret_id = aws_secretsmanager_secret.sg_postgres_db_password.id
  secret_string = random_password.sg_postgres_db_password.result
}

data "aws_secretsmanager_secret" "sg_postgres_db_password" {
  name = "sg-db-password"
}

data "aws_secretsmanager_secret_version" "sg_postgres_db_password" {
  secret_id = data.aws_secretsmanager_secret.sg_postgres_db_password.id
}

# US RDS 
resource "aws_db_instance" "us_rds" {
  provider             = aws.us-east-1  
  allocated_storage    = var.rds_storage
  db_name              = var.rds_name
  engine               = "postgres"
  engine_version       = var.rds_engine_version
  instance_class       = var.rds_instance_size
  username             = var.rds_username
  password             = data.aws_secretsmanager_secret_version.us_postgres_db_password.secret_string
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.us_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.us_rds_sg.id]
}

resource "aws_security_group" "us_rds_sg" {
  provider    = aws.us-east-1
  name        = "us-rds-sg"
  description = "Security group for US RDS"
  vpc_id      = aws_vpc.us_vpc.id

  ingress {
    description      = "RDS from private subnet"
    from_port        = var.rds_port
    to_port          = var.rds_port
    protocol         = "tcp"
    cidr_blocks     = [var.tier_2_a_cidr,var.tier_2_b_cidr]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "us_db_subnet_group" {
  name       = "us_db_subnet_group"
  subnet_ids = [aws_subnet.us_tier_2_a.id,aws_subnet.us_tier_2_b.id]

  tags = {
    Environment = var.environment
  }
}

resource "random_password" "us_postgres_db_password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "us_postgres_db_password" {
  provider             = aws.us-east-1  
  name = "us-db-password"
  tags                    = {
    Environment           = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "us_postgres_db_password" {
  provider  = aws.us-east-1
  secret_id = aws_secretsmanager_secret.us_postgres_db_password.id
  secret_string = random_password.us_postgres_db_password.result
}

data "aws_secretsmanager_secret" "us_postgres_db_password" {
  name = "us-db-password"
}

data "aws_secretsmanager_secret_version" "us_postgres_db_password" {
  secret_id = data.aws_secretsmanager_secret.us_postgres_db_password.id
}