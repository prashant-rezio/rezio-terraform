 output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "ecs_cluster_name" {
  value = module.ecs_fargate.ecs_cluster_name
}
