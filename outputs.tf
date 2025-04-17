output "vpc_id" {
  description = "VPC ID created by the vpc module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs created by the vpc module"
  value       = module.vpc.public_subnet_ids
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}