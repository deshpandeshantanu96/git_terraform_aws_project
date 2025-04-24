variable "vpc_id" {
  description = "The VPC ID where the security group should be created"
  type        = string
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "Allowed CIDR blocks for RDS access"
  type        = list(string)
}
