vpc_config = {
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnet_count  = 2  # Optional if needed inside module
}

bastion_config = {
  my_ip    = "110.226.177.255/32"
  key_name = "terraform_application_key"
}

alb_config = {
  acm_certificate_arn = "arn:aws:acm:us-east-1:445567099825:certificate/c7f40eaf-0ffc-4b11-bd65-b62860e1d853"
}

rds_config = {
  db_username       = "adminuser"
  db_password       = "StrongPassword123"
  db_name           = "testdb"
  db_instance_class = "db.t3.micro"
  vpc_cidr          = ["0.0.0.0/0"]
  vpc_id            = "vpc-12345678"       # Your existing VPC ID
  subnet_ids        = ["subnet-123456", "subnet-654321"]
}

eks_config = {
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  region          = "us-east-1"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-123456", "subnet-654321"]

  node_groups = {
    primary = {
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"  # <-- THIS WAS MISSING
      instance_types = ["t3.medium"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      disk_size      = 20
    }
    spot = {
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"      # <-- THIS WAS MISSING
      instance_types = ["t3.medium", "t3.large"]
      desired_size   = 1
      max_size       = 3
      min_size       = 1
      disk_size      = 20
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}