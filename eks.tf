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
  
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
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

  eks_managed_node_groups = {
    csye7125_node_group = {
      name                   = var.node_group_name
      create_iam_role        = false
      iam_role_arn           = aws_iam_role.node_role.arn
      instance_types         = var.instance_types[*]
      min_size               = var.min_size
      max_size               = var.max_size
      desired_size           = var.desired_size
      vpc_security_group_ids = [aws_security_group.node.id]
      update_config = {
        max_unavailable = var.max_unavailable_number
      }
      ebs_optimized = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            iops                  = 5000
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

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ~/.kube/config
      aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name} --profile ${var.profile}
    EOT
  }

  depends_on = [kubernetes_namespace.ns2]
}

resource "null_resource" "dependency" {
  provisioner "local-exec" {
    command = "sleep 5"
  }

  depends_on = [aws_eip.nat[0], aws_eip.nat[1], aws_eip.nat[2], aws_iam_policy.eks_kms_policy, aws_iam_policy.eks_kms_policy_ebs, aws_iam_role.cluster_role, aws_iam_role.node_role, aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment["AmazonEBSCSIDriverPolicy"], aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment["AmazonEKSClusterPolicy"], aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment["AmazonEKSVPCResourceController"], aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment["AmazonEKS_CNI_Policy"], aws_iam_role_policy_attachment.eks_kms_policy_attachment, aws_iam_role_policy_attachment.eks_kms_policy_attachment_ebs, aws_iam_role_policy_attachment.eks_node_role_policy_attachment["AmazonEBSCSIDriverPolicy"], aws_iam_role_policy_attachment.eks_node_role_policy_attachment["AmazonEC2ContainerRegistryReadOnly"], aws_iam_role_policy_attachment.eks_node_role_policy_attachment["AmazonEKSWorkerNodePolicy"], aws_iam_role_policy_attachment.eks_node_role_policy_attachment["AmazonEKS_CNI_Policy"], aws_internet_gateway.gateway, aws_kms_key.ebs, aws_kms_key.eks, aws_nat_gateway.natgw[0], aws_nat_gateway.natgw[1], aws_nat_gateway.natgw[2], aws_route_table.private_subnet_route_table[0], aws_route_table.private_subnet_route_table[1], aws_route_table.private_subnet_route_table[2], aws_route_table.public_subnet_route_table[0], aws_route_table.public_subnet_route_table[1], aws_route_table.public_subnet_route_table[2], aws_route_table_association.private_subnet[0], aws_route_table_association.private_subnet[1], aws_route_table_association.private_subnet[2], aws_route_table_association.public_subnet[0], aws_route_table_association.public_subnet[1], aws_route_table_association.public_subnet[2], aws_security_group.cluster, aws_security_group.node, aws_security_group_rule.cluster_egress[0], aws_security_group_rule.cluster_ingress[0], aws_security_group_rule.node_egress[0], aws_subnet.private_subnets[0], aws_subnet.private_subnets[1], aws_subnet.private_subnets[2], aws_subnet.public_subnets[0], aws_subnet.public_subnets[1], aws_subnet.public_subnets[2], aws_vpc.main, module.eks]
}

resource "null_resource" "apply_metrics_server" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
  }
  depends_on = [null_resource.update_kubeconfig]
}