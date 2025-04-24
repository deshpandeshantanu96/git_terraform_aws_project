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

}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.cluster_name}-node-"
  instance_type = "t2.medium"  # Overrides instance_types in node group
  key_name      = "terraform_application_key"  # For SSH access

  # Assign the custom security group
  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  # Required for EKS nodes
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-worker-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}