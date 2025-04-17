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


variable "eks_config" {
  description = "Configuration for the EKS cluster"
  type = object({
    name            = string
    version         = string
    vpc_id          = string
    subnet_ids      = list(string)
    region          = string
    bastion_config  = object({
      enabled   = bool
      ip        = string
      key_name  = string
    })
  })

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,99}$", var.eks_config.name))
    error_message = "EKS cluster name must be 1-100 characters long, start with a letter, and can contain only alphanumeric characters and hyphens."
  }
}