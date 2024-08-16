resource "aws_acm_certificate" "cert" {
  domain_name       = "web.illur.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.zoneid 
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "kubernetes_config_map" "acm_cert_arn" {
  metadata {
    name      = "acm"
    namespace = "cve-generator"
  }

  data = {
    acm_certificate_arn = aws_acm_certificate.cert.arn
  }
  depends_on = [kubernetes_namespace.cve-generator, null_resource.apply_metrics_server, helm_release.istio_ingress]
}