variable "vpc_config" {
  description = "VPC and subnet configuration"
  type = object({
    vpc_cidr            = string
    public_subnet_cidrs = list(string)
    private_subnet_cidrs = list(string)
  })
}

variable "bastion_config" {
  description = "Configuration for the bastion host"
  type = object({
    my_ip    = string
    key_name = string
  })
}

variable "alb_config" {
  description = "Configuration for the ALB"
  type = object({
    acm_certificate_arn = string
  })
}


# Basic EKS Config (only few fields manually from tfvars)
variable "eks_config" {
  description = "Base configuration for the EKS Cluster. Full config is completed using outputs in locals."
  type = object({
    name    = string
    version = string
    region  = string
  })

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,99}$", var.eks_config.name))
    error_message = "EKS cluster name must be 1-100 characters long, start with a letter, and can contain only alphanumeric characters and hyphens."
  }
}