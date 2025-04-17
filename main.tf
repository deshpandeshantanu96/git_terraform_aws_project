module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_config.vpc_cidr
  public_subnet_cidrs = var.vpc_config.public_subnet_cidrs
  private_subnet_cidrs = var.vpc_config.private_subnet_cidrs
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  my_ip            = var.bastion_config.my_ip
  key_name         = var.bastion_config.key_name
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = var.alb_config.acm_certificate_arn
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.eks_config.name
  cluster_version = var.eks_config.version
  vpc_id          = var.eks_config.vpc_id
  subnet_ids      = var.eks_config.subnet_ids
  region          = var.eks_config.region
  bastion_ip      = module.bastion.bastion_public_ip
}
