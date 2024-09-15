 variable "region" {
  description = "AWS Region"
  default     = "me-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  default     = "10.10.0.0/16"
}
variable "db_password" {
  description = "Master password for the RDS database"
  sensitive   = true
}

