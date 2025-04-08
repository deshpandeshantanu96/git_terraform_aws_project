variable "bastion_inputs" {
  description = "Inputs for bastion module"
  type = object({
    vpc_id            = string
    public_subnet_id  = string
    my_ip             = string
    key_name          = string
  })
}