variable "vpc_id" {
  description = "VPC ID for the Bastion host"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the Bastion host"
  type        = string
}

variable "my_ip" {
  description = "Your IP address to allow SSH access"
  type        = string
}

variable "key_name" {
  description = "Key pair name to SSH into the Bastion EC2"
  type        = string
}