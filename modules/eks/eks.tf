provider "aws" {
  region = var.region 
}

#IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com",
        },
      },
    ],
  })
}

#IAM Policy Attachment for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

#EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [var.private1_subnet_id, var.private2_subnet_id]
  }
  tags = {
    name = "${var.project_name_env}-eks-cluster"
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_attachment]
}

#IAM Role for EKS Managed Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}
#IAM Policy Attachment for EKS Managed Node Group
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# EKS Managed Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.eks-node
  subnet_ids      = [var.private1_subnet_id, var.private2_subnet_id]
  scaling_config {
    desired_size = var.desired_nodes    
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  node_role_arn          = aws_iam_role.eks_node_group.arn

  instance_types = [var.instance_types]
  capacity_type  = var.capacity_type
  ami_type = var.ami_type

  # labels = {
  #   role = "managed-nodes"
  # }

  tags = {
    name = "${var.project_name_env}-eks-worker-node"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks,
  ]
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "eks_node_group_instance_profile" {
  name = "eks-node-group-instance-profile"
  role = aws_iam_role.eks_node_group.name
}
