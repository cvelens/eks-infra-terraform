

resource "helm_release" "kafka" {
  name       = var.kafka_name
  repository = var.helm_kafka_repo
  chart      = var.chart_name
  values     = [file("kafka-config.yaml")]
  namespace  = kubernetes_namespace.ns2.metadata[0].name
  depends_on = [kubernetes_namespace.ns2]
}