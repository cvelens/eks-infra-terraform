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

resource "kubernetes_resource_quota" "ns1" {
  metadata {
    name      = var.nsquota
    namespace = kubernetes_namespace.ns1.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "4Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "24Gi"
    }
  }
  depends_on = [helm_release.kafka]
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

resource "kubernetes_resource_quota" "ns2" {
  metadata {
    name      = var.nsquota
    namespace = kubernetes_namespace.ns2.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "16"
      "limits.memory"   = "30Gi"
    }
  }
  depends_on = [helm_release.kafka]
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

resource "kubernetes_namespace" "cve-operator-system" {
  metadata {
    labels = {
      namespace = "cve-operator-system"
    }

    name = "cve-operator-system"
  }
  depends_on = [null_resource.dependency]
}

resource "kubernetes_resource_quota" "ns3" {
  metadata {
    name      = var.nsquota
    namespace = kubernetes_namespace.ns3.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "4Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "24Gi"
    }
  }
  depends_on = [helm_release.kafka]
}

resource "kubernetes_namespace" "ns4" {
  metadata {
    labels = {
      namespace = "ns4"
    }

    name = "ns4"
  }
  depends_on = [null_resource.dependency]
}

resource "kubernetes_secret" "github" {
  metadata {
    name      = var.secret_name
    namespace = kubernetes_namespace.cve-operator-system.metadata[0].name
  }

  data = {
    token = var.token
  }
  depends_on = [kubernetes_namespace.cve-operator-system]
}

resource "kubernetes_resource_quota" "ns4" {
  metadata {
    name      = var.nsquota
    namespace = kubernetes_namespace.ns4.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "0.5"
      "requests.memory" = "2Gi"
      "limits.cpu"      = "2"
      "limits.memory"   = "8Gi"
    }
  }
  depends_on = [helm_release.kafka]
}