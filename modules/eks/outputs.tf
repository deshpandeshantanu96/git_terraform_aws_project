output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster"
  value       = aws_security_group.cluster.id
}

output "node_role_arn" {
  description = "ARN of the worker nodes IAM role"
  value       = aws_iam_role.nodes.arn
}

output "node_groups" {
  description = "Outputs of all node groups"
  value       = aws_eks_node_group.this
}