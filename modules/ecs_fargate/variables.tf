variable "vpc_id" {
  description = "VPC ID where ECS Fargate will run"
}

variable "public_subnets" {
  description = "Public subnets for the ECS tasks"
}

variable "private_subnets" {
  description = "Private subnets for ECS"
}

variable "cluster_name" {
  description = "ECS Cluster Name"
}
variable "backend_image" {
  description = "Backend Docker image from ECR"
}

variable "region" {
  description = "AWS Region"
  default     = "me-central-1"  # Change this to your preferred region
}
