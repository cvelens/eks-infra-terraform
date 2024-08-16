resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "aws.assumeRoleArn"
    value = aws_iam_role.node_role.arn
  }

  set {
    name  = "domainFilters[0]"
    value = "illur.cloud"
  }

  set {
    name  = "txtOwnerId"
    value = "external-dns"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
  depends_on = [kubernetes_namespace.cve-generator, null_resource.apply_metrics_server, helm_release.istio_ingress]
}
