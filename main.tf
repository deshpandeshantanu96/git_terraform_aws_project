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

module "rds" {
  source = "./modules/rds"

  vpc_id            = module.vpc.vpc_id
  db_username       = var.rds_config.db_username
  db_password       = var.rds_config.db_password
  db_name           = var.rds_config.db_name
  db_instance_class = var.rds_config.db_instance_class
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_cidr          = var.rds_config.vpc_cidr
}

resource "aws_security_group" "internal_lb_sg" {
  name        = "internal-lb-sg"
  description = "Security Group for Internal Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # your VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source = "./modules/eks"

  # Basic cluster config
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  
  # Node groups config (properly nested)
  node_groups = {
    primary = {
      ami_type       = var.ami_type
      instance_types = var.instance_types
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      disk_size      = var.disk_size
      capacity_type  = var.capacity_type
    }
  }
}