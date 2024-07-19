

resource "helm_release" "kafka" {
  name       = var.kafka_name
  repository = var.helm_kafka_repo
  chart      = var.chart_name
  values     = [file("kafka-config.yaml")]
  namespace  = kubernetes_namespace.ns2.metadata[0].name
  depends_on = [kubernetes_namespace.ns2, null_resource.apply_metrics_server]
}

resource "kubernetes_secret" "dockerhub" {
  metadata {
    name      = "dockerhub-secret"
    namespace = kubernetes_namespace.ns4.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.dockerhub_username
          "password" = var.dockerhub_password
          "email"    = var.dockerhub_email
          "auth"     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    })
  }
}

resource "null_resource" "helm_install" {
  provisioner "local-exec" {
    command = <<EOT
    latest_release=$(curl -L -s -H "Authorization: token ${var.gh_token}" "https://api.github.com/repos/cyse7125-su24-team15/helm-eks-autoscaler/releases/latest" | jq -r '.assets[0].url')
    curl -L -s -H "Authorization: token ${var.gh_token}" -H 'Accept:application/octet-stream' "$latest_release" -o asset.tgz
    tar -zxvf asset.tgz
    helm install cluster-autoscaler cluster-autoscaler-*.tgz -n ns4
    EOT
    environment = {
      GITHUB_TOKEN = var.gh_token
    }
  }
  depends_on = [null_resource.update_kubeconfig]
}