
rezio-terraform/
├── main.tf
├── backend.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── ecs_fargate/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── variables.tf

Step 1: Set Up Terraform State Management (S3 + DynamoDB)
We'll begin by setting up Terraform State Management using an S3 bucket for state storage and a DynamoDB table for state locking.

Create the S3 bucket and DynamoDB table manually through Terraform without the backend configuration first, and then reconfigure Terraform to use them as the backend.
1.1. Set Up S3 Bucket and DynamoDB Table
Start with this Terraform configuration to create the S3 bucket and DynamoDB table:

hcl
Copy code
provider "aws" {
  region = "us-east-1"  # Your region, change to what works for you
}

# Create the S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "my-terraform-state-bucket-unique-id"  # Use a unique bucket name
  acl    = "private"

  versioning {
    enabled = true  # Enable versioning for backup
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Create the DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
1.2. Apply the Configuration to Create Resources
Run the following commands to initialize and apply the Terraform configuration:

bash
Copy code
terraform init
terraform apply -auto-approve
This will create the S3 bucket and DynamoDB table required for state management.

Step 2: Configure Terraform Backend to Use S3 and DynamoDB
Once the resources are created, we can configure Terraform to use the S3 bucket and DynamoDB for managing the state.

2.1. Update Backend Configuration
Now that the resources exist, we will configure Terraform to use them:

hcl
Copy code
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-id"  # Replace with the actual bucket name
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"  # Replace with the actual DynamoDB table name
  }
}
2.2. Reinitialize Terraform with the Backend
Reinitialize Terraform with the new backend configuration:

bash
Copy code
terraform init -reconfigure
This will migrate the local state to the S3 bucket and enable state locking with DynamoDB.

Step 3: Build Infrastructure (VPC, Subnets, ECS, RDS)
Next, we’ll modularize the infrastructure setup to reflect your free-tier setup. The first step will be creating a VPC, public and private subnets, and security groups.

3.1. Modularize VPC Setup
We’ll create a separate module for the VPC setup.

Folder structure:

markdown
Copy code
└── modules/
    └── vpc/
        └── vpc.tf
VPC Module (modules/vpc/vpc.tf):

hcl
Copy code
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_a_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Adjust based on your region

  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_b_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"  # Adjust based on your region

  tags = {
    Name = "Public Subnet B"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet B"
  }
}

# Module Variables
variable "cidr_block" {}
variable "vpc_name" {}
variable "public_subnet_a_cidr" {}
variable "public_subnet_b_cidr" {}
variable "private_subnet_a_cidr" {}
variable "private_subnet_b_cidr" {}
Define the VPC Module in main.tf:

hcl
Copy code
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  vpc_name   = "my-free-tier-vpc"
  public_subnet_a_cidr = "10.0.1.0/24"
  public_subnet_b_cidr = "10.0.2.0/24"
  private_subnet_a_cidr = "10.0.3.0/24"
  private_subnet_b_cidr = "10.0.4.0/24"
}