# modules/eks/variables.tf

variable "name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "version" {
  description = "Kubernetes version for the EKS Cluster"
  type        = string
}

variable "region" {
  description = "AWS region to deploy EKS Cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS Cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs for EKS"
  type        = list(string)
}

variable "role_arn" {
  description = "IAM Role ARN for the EKS Control Plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN for the EKS Node Group"
  type        = string
}

variable "bastion_ip" {
  description = "Public IP of Bastion host for restricted Kubernetes API access (optional)"
  type        = string
}
