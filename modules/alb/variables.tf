variable "vpc_id" {
  description = "VPC ID for ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}