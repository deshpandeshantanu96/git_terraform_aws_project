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
  role_arn        = aws_iam_role.eks_cluster_role.arn  # Pass the created role here
  node_role_arn   = aws_iam_role.eks_node_role.arn
  
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_policy.json
}

data "aws_iam_policy_document" "eks_node_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


