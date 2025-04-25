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

eks_config = {
  cluster_name    = "dev-eks-cluster-2"
  cluster_version = "1.29"
  region          = "us-east-1"
}

node_group_config = {
  instance_type      = "t3.medium"
  desired_capacity   = 2
  max_capacity       = 3
  min_capacity       = 1
  ami_type           = "AL2_x86_64"
  key_pair           = "terraform_application_key"   # Replace with your SSH key name if necessary
}

lb_controller_config = {
  enable_controller   = true
  service_account_name = "aws-load-balancer-controller"
}

rds_config = {
  db_username       = "adminuser"
  db_password       = "StrongPassword123"
  db_name           = "testdb"
  db_instance_class = "db.t3.micro"
  vpc_cidr          = ["0.0.0.0/0"]
}
