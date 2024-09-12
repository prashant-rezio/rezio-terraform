
# **Rezio Production Environment Setup with Terraform**

This repository contains the Terraform configuration for setting up the production environment for **Rezio** on AWS. The setup includes a VPC, RDS (PostgreSQL), ECS Fargate, Load Balancer, Security Groups, and other related infrastructure components.

## **Directory Structure**

The Terraform configuration follows a **modular approach** for better organization, scalability, and maintainability. Each resource group (VPC, RDS, ECS) is defined as a separate module, allowing for easier reuse and updates.

```bash
rezio-prod-terraform/
├── main.tf                 # Main Terraform configuration stitching modules together
├── outputs.tf              # Outputs for useful details like VPC ID, ALB DNS name, etc.
├── variables.tf            # Input variables for Terraform configuration
├── backend.tf              # S3 backend configuration for storing Terraform state
├── modules/                # Directory containing the individual modules
│   ├── vpc/                # VPC module definition
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                # RDS (PostgreSQL) module definition
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ecs_fargate/        # ECS Fargate module definition
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

---

## **Approach and Good Practices**

This Terraform setup follows several **best practices** to ensure reliability, maintainability, and scalability:

### **1. Modular Approach**
Each component (VPC, RDS, ECS) is built as a separate module. This allows:
- **Reusability**: You can easily reuse the same VPC, RDS, or ECS modules for other environments (e.g., staging, development).
- **Maintainability**: Changes are isolated, making it easier to update individual components without affecting the entire setup.

### **2. Remote State Management**
- **S3 and DynamoDB** are used for Terraform state management and state locking:
  - S3 bucket (`rezio-terraform-state`) stores the Terraform state file.
  - DynamoDB table (`rezio-terraform-locks`) is used to prevent multiple operations from modifying the same state concurrently, ensuring consistency.

### **3. Security Best Practices**
- **Least Privilege Security Groups**: Security groups are carefully configured to allow only necessary traffic (e.g., ALB to ECS, ECS to RDS, etc.).
- **Multi-AZ Deployment**: RDS (PostgreSQL) is deployed across multiple availability zones for high availability and disaster recovery.

### **4. Scalability and Auto-Scaling**
- The ECS Fargate cluster is configured to support auto-scaling based on traffic and resource usage, ensuring that the environment can handle varying workloads.

### **5. Logs and Monitoring**
- **CloudWatch logs** are enabled for ECS services, allowing centralized logging and monitoring of service performance.

---

## **Infrastructure Components**

### **1. VPC Setup**
- **VPC Name**: `rezio-prod-vpc`
- **CIDR Block**: `10.10.0.0/16`
- **Subnets**:
  - Public Subnets: 
    - `rezio-public-subnet-1`: `10.10.1.0/24` in `me-central-1a`
    - `rezio-public-subnet-2`: `10.10.2.0/24` in `me-central-1b`
  - Private Subnets:
    - `rezio-private-subnet-1`: `10.10.3.0/24` in `me-central-1a`
    - `rezio-private-subnet-2`: `10.10.4.0/24` in `me-central-1b`

  **Verification**:
  ```bash
  aws ec2 describe-vpcs --filters "Name=cidr,Values=10.10.0.0/16"
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=<Your_VPC_ID>"
  ```

### **2. RDS (PostgreSQL) Setup**
- **Database Name**: `rezio-prod-db`
- **Engine**: PostgreSQL
- **Multi-AZ**: Enabled
- **Allocated Storage**: 50 GB (auto-scaling enabled)
- **Custom Port**: 5433

  **Verification**:
  ```bash
  aws rds describe-db-instances --filters "Name=db-instance-id,Values=rezio-prod-db"
  ```

### **3. Load Balancer (ALB) Setup**
- **ALB Name**: `rezio-prod-alb`
- **Internet-Facing**: Yes
- **Public Subnets**: 
  - `rezio-public-subnet-1`
  - `rezio-public-subnet-2`

  **Verification from cli**:
  ```bash
  aws elbv2 describe-load-balancers --names rezio-prod-alb
  ```

### **4. ECS Fargate Cluster**
- **Cluster Name**: `rezio-prod-cluster`
- **ECS Task Definitions**: For core backend and AI services
- **Auto-Scaling**: Configured to handle traffic spikes.

  **Verification**:
  ```bash
  aws ecs describe-clusters --clusters rezio-prod-cluster
  aws ecs describe-task-definitions --task-definition <Task_Definition_Name>
  ```

### **5. Security Groups**
- **rezio-ecs-sg**: Allows traffic from ALB to ECS.
- **rezio-alb-sg**: Allows traffic from Cloudflare, blocks others.
- **rezio-rds-sg**: Allows ECS to connect to RDS on port `5433`.

  **Verification**:
  ```bash
  aws ec2 describe-security-groups --group-names rezio-ecs-sg rezio-alb-sg rezio-rds-sg
  ```

---

## **How to Use**

### **1. Initialize Terraform**
Before applying the configuration, initialize the Terraform working directory to install necessary providers and modules:

```bash
terraform init
```

### **2. Plan the Changes (Dry Run)**
Run `terraform plan` to see what changes Terraform will apply:

```bash
terraform plan
```

### **3. Apply the Configuration**
After reviewing the plan, apply the changes to create the infrastructure:

```bash
terraform apply
```

### **4. Store Terraform State Remotely**
Terraform state is stored in an S3 bucket (`rezio-terraform-state`) with locking enabled via DynamoDB to ensure consistency across teams.

---

## **Best Practices Followed**

1. **Modularity**: Each major resource (VPC, RDS, ECS) is broken into modules to enhance reusability and maintainability.
2. **Remote State**: Terraform state is stored in S3, and state locking is enabled using DynamoDB to prevent concurrent updates.
3. **Security**: Security groups are configured with the principle of least privilege, only allowing necessary traffic between resources.
4. **High Availability**: RDS is configured with Multi-AZ deployment to ensure high availability.
5. **Auto-Scaling**: ECS Fargate is configured with auto-scaling to handle traffic spikes automatically.
6. **Logging**: CloudWatch logs are enabled for ECS tasks, providing centralized monitoring of the environment.

---

### **Resources Used:**
- **AWS VPC Module**: For creating the VPC and its subcomponents (subnets, route tables, NAT Gateway, etc.).
- **AWS RDS Module**: For creating a highly available PostgreSQL database.
- **AWS ECS Fargate Module**: For deploying ECS tasks using Docker images from ECR.
- **AWS Application Load Balancer (ALB)**: For balancing traffic between ECS tasks.

---
