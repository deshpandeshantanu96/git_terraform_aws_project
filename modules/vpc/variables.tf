variable "vpc_inputs" {
  description = "VPC input object"
  type = object({
    vpc_cidr            = string
    public_subnet_cidrs = list(string)
    private_subnet_cidrs = list(string)
  })
}
