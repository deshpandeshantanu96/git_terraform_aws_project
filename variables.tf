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
