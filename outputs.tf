output "vpc_id" {
  description = "VPC ID created by the vpc module"
  value       = module.vpc.vpc_id
}

output "internal_lb_sg_id" {
  value = aws_security_group.internal_lb_sg.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs created by the vpc module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Public subnet IDs created by the vpc module"
  value       = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
