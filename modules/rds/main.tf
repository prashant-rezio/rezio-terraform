resource "aws_security_group" "rds_sg" {
  name        = "rezio-rds-sg"
  description = "Allow access to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_cidr_blocks  # Use CIDR blocks here
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rezio_prod_db" {
  identifier           = var.db_name
  engine               = "postgres"
  instance_class       = "db.t3.medium"
  allocated_storage    = 50
  multi_az             = true
  port                 = var.db_port
  username             = var.db_username       # Add this line
  password             = var.db_password       # Add this line (password should be securely stored)
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rezio_prod_subnet.name
  storage_encrypted    = true
  backup_retention_period = 7
}

resource "aws_db_subnet_group" "rezio_prod_subnet" {
  name       = "rezio-prod-db-subnet"
  subnet_ids = var.subnet_ids  # Using the subnet_ids passed from the root module

  tags = {
    Name = "rezio-prod-db-subnet"
  }
}
