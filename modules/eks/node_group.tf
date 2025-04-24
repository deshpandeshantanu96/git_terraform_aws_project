# modules/eks/main.tf

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t2.medium"]
  
  # Attach the node security group
  remote_access {
    ec2_ssh_key = "terraform_application_key"
  }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  # Associate the node security group
  vpc_security_group_ids = [aws_security_group.eks_nodes.id]
}