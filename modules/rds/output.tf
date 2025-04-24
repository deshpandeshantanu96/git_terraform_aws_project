output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.free_tier_db.endpoint
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_group_name" {
  description = "RDS Subnet Group Name"
  value       = aws_db_subnet_group.rds_subnet_group.name
}
