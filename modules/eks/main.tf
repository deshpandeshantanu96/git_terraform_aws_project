resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

resource "aws_eks_addon" "core_addons" {
  for_each = { for addon in ["coredns", "kube-proxy", "vpc-cni"] : addon => addon }

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  depends_on = [
    aws_eks_node_group.this
  ]
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}