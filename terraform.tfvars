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

# terraform.tfvars

# EKS Cluster and Node Group Configuration
eks_config = {
  cluster_name    = "my-eks-cluster-aws"
  cluster_version = "1.27"
  ami_type        = "AL2_x86_64"             # AMI type for the node group
  instance_types  = ["t3.medium", "t3.large"] # Instance types for the node group
  desired_size    = 2                          # Desired number of nodes
  max_size        = 3                          # Max number of nodes
  min_size        = 1                          # Min number of nodes
  disk_size       = 20                         # EBS volume size in GB
  capacity_type   = "ON_DEMAND"                # Capacity type (ON_DEMAND or SPOT)
}

# Optional: Tags for the resources
tags = {
  Environment = "dev"
  Terraform   = "true"
}
