module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "bastion" {
  source = "./modules/bastion"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  my_ip = var.my_ip
  key_name = var.key_name
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = var.acm_certificate_arn
}
