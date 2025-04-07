module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_config.vpc_cidr
  public_subnet_cidrs = var.vpc_config.public_subnet_cidrs
  private_subnet_cidrs = var.vpc_config.private_subnet_cidrs
}

module "bastion" {
  source = "./modules/bastion"
  bastion_inputs = {
    vpc_id           = module.vpc.vpc_id
    public_subnet_id = module.vpc.public_subnet_ids[0]
    my_ip            = var.bastion_config.my_ip
    key_name         = var.bastion_config.key_name
  }
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = var.alb_config.acm_certificate_arn
}