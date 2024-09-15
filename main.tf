# Main Configuration to Stitch Modules Together
terraform {
  backend "s3" {
    bucket         = "rezio-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "me-central-1"
    dynamodb_table = "rezio-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "me-central-1"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.10.0.0/16"
}

module "rds" {
  source                    = "./modules/rds"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  private_subnets_cidr_blocks = ["10.10.3.0/24", "10.10.4.0/24"]
  db_name                   = "rezio-prod-db"
  db_port                   = 5433
  db_username               = "masteruser"             # Set your DB master username here
  db_password               = var.db_password          # Pass the password securely
}


# ECS Fargate Module
module "ecs_fargate" {
  source          = "./modules/ecs_fargate"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  cluster_name    = "rezio-prod-cluster"
  backend_image   = "767397806684.dkr.ecr.me-central-1.amazonaws.com/rezio-be:development"
  execution_role_arn = "arn:aws:iam::767397806684:role/ecsTaskExecutionRole"  # Pass the existing IAM role ARN
}
