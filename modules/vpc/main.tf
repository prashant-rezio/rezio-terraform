module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0"
  
  name = "rezio-prod-vpc"
  cidr = var.vpc_cidr

  azs               = ["me-central-1a", "me-central-1b"]
  public_subnets    = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets   = ["10.10.3.0/24", "10.10.4.0/24"]

  enable_nat_gateway = true
}
