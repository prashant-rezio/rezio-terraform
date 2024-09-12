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

# RDS Module
module "rds" {
  source      = "./modules/rds"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  db_name     = "rezio-prod-db"
  db_port     = 5433
}

# ECS Fargate Module
module "ecs_fargate" {
  source         = "./modules/ecs_fargate"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  cluster_name   = "rezio-prod-cluster"
  backend_image  = "767397806684.dkr.ecr.me-central-1.amazonaws.com/rezio-be:development"
}
