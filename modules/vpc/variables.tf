variable "alb_inputs" {
  description = "Inputs for ALB module"
  type = object({
    vpc_id            = string
    public_subnet_ids = list(string)
    certificate_arn   = string
  })
}
