resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn
  
  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  version = var.cluster_version
}
