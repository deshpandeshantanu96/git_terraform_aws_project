vpc_config = {
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

bastion_config = {
  my_ip    = "110.226.177.196/32"
  key_name = "terraform_application_key"
}

alb_config = {
  acm_certificate_arn = "arn:aws:acm:us-east-1:445567099825:certificate/003dc0a6-707e-403e-a87a-7a07378b5737"
}
