# modules/eks/variables.tf

# EKS Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy the EKS cluster."
  type        = string
}

# VPC and Subnet Configuration
variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster."
  type        = list(string)
}

# Node Group Configuration
variable "node_group_config" {
  description = "Configuration for the EKS node group."
  type = object({
    instance_type    = string
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    ami_type         = string
    key_pair         = string
  })
}

# Load Balancer Controller Configuration
variable "lb_controller_config" {
  description = "Configuration for the AWS Load Balancer Controller."
  type = object({
    enable_controller   = bool
    service_account_name = string
  })
}
