resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_public_access = true
  }

  version = var.cluster_version

  depends_on = [
    aws_iam_role_policy_attachment.eks_role_policy_attachment
  ]
}

# modules/eks/main.tf

# Security group for EKS control plane (created by AWS, but we add rules)
resource "aws_security_group_rule" "eks_ingress_nodes" {
  description              = "Allow worker nodes to communicate with EKS API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# modules/eks/main.tf

# Security group for worker nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

# Allow EKS control plane to communicate with worker nodes
resource "aws_security_group_rule" "node_ingress_eks" {
  description              = "Allow EKS control plane to communicate with worker nodes"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# Optional: Allow SSH access (if debugging is needed)
resource "aws_security_group_rule" "node_ingress_ssh" {
  description       = "Allow SSH access to worker nodes"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = ["10.0.0.0/16"]  # Restrict to your VPC or specific IPs
}
