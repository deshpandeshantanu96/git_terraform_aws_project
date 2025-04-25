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

variable "rds_config" {
  description = "Configuration for RDS module"
  type = object({
    db_username        = string
    db_password        = string
    db_name            = string
    db_instance_class  = string
    subnet_ids         = list(string)
    vpc_cidr           = list(string)
  })
}

variable "eks_config" {
  description = "Configuration for eks module"
  type = object({
    cluster_name    = string
    cluster_version = string
    ami_type       = string
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
    disk_size      = number
    capacity_type  = string
  })
}