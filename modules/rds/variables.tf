variable "vpc_id" {
  description = "VPC ID to launch RDS in"
}

variable "subnet_ids" {
  description = "Subnets for the RDS instance"
}

variable "db_name" {
  description = "Name of the RDS database"
}

variable "db_port" {
  description = "Custom port for the PostgreSQL RDS instance"
  default     = 5433
}
