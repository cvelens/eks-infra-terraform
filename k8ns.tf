data "aws_eks_cluster_auth" "default" {
  name       = var.cluster_name
  depends_on = [module.eks]
}
data "aws_eks_cluster" "default" {
  name       = var.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--region", var.region,
      "--cluster-name", var.cluster_name,
      "--output", "json"
    ]
    env = {
      AWS_PROFILE = var.profile
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--region", var.region,
        "--cluster-name", var.cluster_name,
        "--output", "json"
      ]
      env = {
        AWS_PROFILE = var.profile
      }
    }
  }
}

resource "kubernetes_namespace" "ns1" {
  metadata {
    labels = {
      namespace = "ns1"
    }

    name = "ns1"
  }
  depends_on = [null_resource.dependency]
}

resource "kubernetes_namespace" "ns2" {
  metadata {
    labels = {
      namespace = "ns2"
    }

    name = "ns2"
  }
  depends_on = [null_resource.dependency]
}

resource "kubernetes_namespace" "ns3" {
  metadata {
    labels = {
      namespace = "ns3"
    }

    name = "ns3"
  }
  depends_on = [null_resource.dependency]
}