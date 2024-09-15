# For launching the RDS instance in private subnets
variable "subnet_ids" {
  description = "Subnets for the RDS instance"
  type        = list(string)
}

# For controlling access to RDS using CIDR blocks
variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks for private subnets to allow RDS access"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID to launch RDS in"
}

variable "db_name" {
  description = "Name of the RDS database"
}

variable "db_port" {
  description = "Custom port for the PostgreSQL RDS instance"
  default     = 5433
}

variable "db_username" {
  description = "Master username for the RDS database"
}

variable "db_password" {
  description = "Master password for the RDS database"
  sensitive   = true
}