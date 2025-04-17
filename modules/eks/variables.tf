# modules/eks/variables.tf

variable "cluster_name" {
  description = "Name of the EKS Cluster"
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

variable "region" {
  description = "AWS region to deploy EKS Cluster"
  type        = string
}

variable "bastion_ip" {
  description = "Your IP for allowing access to Kubernetes API (optional if needed)"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS Cluster"
  type        = string
  default     = "1.29" # or whatever latest
}

variable "role_arn" {
  description = "IAM Role ARN for the EKS Cluster"
  type        = string
}

