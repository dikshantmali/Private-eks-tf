# IAM role for EKS Cluster Master

resource "aws_iam_role" "eks-role" {
  name = "Personal-prod-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# attach EKS Cluster Policy to the role created above for EKS Master
resource "aws_iam_role_policy_attachment" "Personal-prod-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}


# IAM Role for Nodegroup

resource "aws_iam_role" "node-role" {
  name = "Personal-prod-eks-nodegrp-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# attach EKS Cluster Policy to the role created above for EKS nodegroup
resource "aws_iam_role_policy_attachment" "Personal-prod-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "Personal-prod-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}
resource "aws_iam_role_policy_attachment" "Personal-prod-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}


# Create SG For EKS Control Plane

resource "aws_security_group" "eks-master-sg" {
  name        = "eks-master-sg"
  description = "Allow TLS inbound traffic to access EKS control plane"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_bastionhost_vpccidr"
  }
}
# EKS Master Creation

resource "aws_eks_cluster" "personal-prod-eks" {
  name     = "Personal-prod-eks"
  role_arn = aws_iam_role.eks-role.arn
  vpc_config {
    subnet_ids = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.public-subnet-3.id,
    aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id]
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids = [aws_security_group.eks-master-sg.id]
  }

}

output "endpoint" {
  value = aws_eks_cluster.personal-prod-eks.endpoint
}

#EKS Addons

resource "aws_eks_addon" "personal-prod-vpc-cni" {
  cluster_name = aws_eks_cluster.personal-prod-eks.name
  addon_name   = "vpc-cni"
}
# Create core dns addon manually
# resource "aws_eks_addon" "personal-prod-coredns" {
#   cluster_name = aws_eks_cluster.personal-prod-eks.name
#   addon_name   = "coredns"
#   addon_version     = "v1.8.7-eksbuild.3"

# }
resource "aws_eks_addon" "personal-prod-kube-proxy" {
  cluster_name = aws_eks_cluster.personal-prod-eks.name
  addon_name   = "kube-proxy"
}

