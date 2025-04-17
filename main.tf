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

locals {
  final_eks_config = merge(
    var.eks_config,  # from dev.tfvars: name, version, region
    {
      vpc_id          = module.vpc.vpc_id
      subnet_ids      = module.vpc.private_subnet_ids
      role_arn        = aws_iam_role.eks_cluster_role.arn
      node_role_arn   = aws_iam_role.eks_node_role.arn
      bastion_ip      = module.bastion.bastion_ip
    }
  )
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = local.final_eks_config.name
  cluster_version = local.final_eks_config.version
  region          = local.final_eks_config.region
  vpc_id          = local.final_eks_config.vpc_id
  subnet_ids      = local.final_eks_config.subnet_ids
  role_arn        = local.final_eks_config.role_arn
  node_role_arn   = local.final_eks_config.node_role_arn
  bastion_ip      = local.final_eks_config.bastion_ip
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
  role       = aws_iam_role.eks_cluster_role.cluster_name
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
  role       = aws_iam_role.eks_node_role.cluster_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.cluster_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_node_role.cluster_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


