module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.14.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.k8_cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  create_iam_role                 = false
  create_kms_key                  = false
  create_cluster_security_group   = false

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                                   = aws_vpc.main.id
  enable_cluster_creator_admin_permissions = true
  subnet_ids                               = aws_subnet.private_subnets[*].id
  control_plane_subnet_ids                 = aws_subnet.public_subnets[*].id
  cluster_security_group_id                = aws_security_group.cluster.id
  iam_role_arn                             = aws_iam_role.cluster_role.arn
  authentication_mode                      = var.authentication_mode
  cluster_encryption_config = { "resources" : ["secrets"]
    provider_key_arn = aws_kms_key.eks.arn
  }
  cluster_ip_family         = var.family
  cluster_enabled_log_types = var.log_types
  eks_managed_node_groups = {
    csye7125_node_group = {
      name            = var.node_group_name
      create_iam_role = false
      iam_role_arn    = aws_iam_role.node_role.arn
      instance_types  = var.instance_types[*]
      min_size        = var.min_size
      max_size        = var.max_size
      destired_size   = var.desired_size
      update_config = {
        max_unavailable = var.max_unavailable_number
      }
      ebs_optimized = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            encrypted             = true
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }
      depends_on = [aws_kms_key.ebs]
      subnet_ids = aws_subnet.private_subnets[*].id
    }
  }
  tags = merge(
    var.cluster_tags
  )
}

