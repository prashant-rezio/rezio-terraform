resource "aws_ecs_cluster" "rezio_prod_cluster" {
  name = var.cluster_name
}

# ECS Task Definition with execution role added
resource "aws_ecs_task_definition" "rezio_backend" {
  family                   = "rezio-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn  # Use the passed execution_role_arn variable
  container_definitions    = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/rezio-prod-backend"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "rezio_backend_service" {
  name            = "rezio-backend-service"
  cluster         = aws_ecs_cluster.rezio_prod_cluster.id
  task_definition = aws_ecs_task_definition.rezio_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  name        = "rezio-ecs-sg"
  description = "Allow ALB to ECS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
