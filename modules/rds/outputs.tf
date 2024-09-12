output "rds_endpoint" {
  value = aws_db_instance.rezio_prod_db.endpoint  # Reference the endpoint from the DB instance only
}
