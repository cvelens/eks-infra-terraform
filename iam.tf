resource "aws_iam_role" "cluster_role" {
  name = "cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "cluster_management_group_policy" {
  for_each = toset(["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController", "AmazonEKS_CNI_Policy", "AmazonEBSCSIDriverPolicy"])
  name     = each.value
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  for_each   = data.aws_iam_policy.cluster_management_group_policy
  role       = aws_iam_role.cluster_role.name
  policy_arn = each.value.arn
}

data "aws_iam_policy_document" "eks_kms_policy" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey", "kms:CreateGrant"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_kms_policy" {
  name   = "eks-kms-policy"
  policy = data.aws_iam_policy_document.eks_kms_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_kms_policy_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = aws_iam_policy.eks_kms_policy.arn
}

resource "aws_iam_role" "node_role" {
  name = "node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_kms_policy_ebs" {
  name   = "eks-kms-policy_ebs"
  policy = data.aws_iam_policy_document.eks_kms_policy_ebs.json
}

data "aws_iam_policy_document" "eks_kms_policy_ebs" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey", "kms:CreateGrant"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_kms_policy_attachment_ebs" {
  role       = aws_iam_role.node_role.name
  policy_arn = aws_iam_policy.eks_kms_policy_ebs.arn
}

data "aws_iam_policy" "node_management_group_policy" {
  for_each = toset(["AmazonEKSWorkerNodePolicy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEKS_CNI_Policy", "AmazonEBSCSIDriverPolicy"])
  name     = each.value
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_attachment" {
  for_each   = data.aws_iam_policy.node_management_group_policy
  role       = aws_iam_role.node_role.name
  policy_arn = each.value.arn
}