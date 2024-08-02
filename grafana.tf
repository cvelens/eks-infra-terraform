resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  depends_on = [
    data.local_file.custom_dashboard1,
    data.local_file.custom_dashboard2,
    data.local_file.custom_dashboard3
  ]
  values = [
    file("grafana.yaml"),
    jsonencode({
      dashboards = {
        default = {
          custom_dashboard1 = {
            json = data.local_file.custom_dashboard1.content
          }
          custom_dashboard2 = {
            json = data.local_file.custom_dashboard2.content
          }
          custom_dashboard3 = {
            json = data.local_file.custom_dashboard3.content
          }
        }
      }
    })
  ]
}

data "local_file" "custom_dashboard1" {
  filename = "dashboards/k8s.json"
}

data "local_file" "custom_dashboard2" {
  filename = "dashboards/postgres.json"
}

data "local_file" "custom_dashboard3" {
  filename = "dashboards/kafka.json"
}

