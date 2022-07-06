# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation

resource "aws_acm_certificate" "www" {
  provider          = aws.cloudfront-acm-certs
  domain_name       = var.custom_domain
  validation_method = "DNS"
}

data "aws_route53_zone" "www" {
  name         = var.hosted_domain
  private_zone = false
}

resource "aws_route53_record" "www" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.www.zone_id
}

resource "aws_acm_certificate_validation" "www" {
  provider                = aws.cloudfront-acm-certs
  certificate_arn         = aws_acm_certificate.www.arn
  validation_record_fqdns = [for record in aws_route53_record.www : record.fqdn]
}
