# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution

resource "aws_cloudfront_origin_access_identity" "s3d" {
  comment = "for ${var.custom_domain} to S3 bucket ${aws_s3_bucket.www.id}"
}

# TODO: 今のところWAFとloggingなし
# tfsec:ignore:aws-cloudfront-enable-waf tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "s3_distribution" {
  # S3をoriginにする場合こっちを使うこと
  # ただしsubdirのindex.htmlつかえない
  # origin {
  #   domain_name = aws_s3_bucket.www.bucket_regional_domain_name
  #   origin_id   = aws_s3_bucket.www.id
  #   s3_origin_config {
  #     origin_access_identity = aws_cloudfront_origin_access_identity.s3d.cloudfront_access_identity_path
  #   }
  # }

  # S3 static webの時のorigin
  origin {
    domain_name = aws_s3_bucket_website_configuration.www.website_endpoint
    origin_id   = aws_s3_bucket.www.id # ここはもう少し考えたほうがいいかも。s3originの時と変えるべきかも。

    custom_origin_config {
      http_port              = 80
      origin_protocol_policy = "http-only"
      https_port             = 443         # 無視される(はず)
      origin_ssl_protocols   = ["TLSv1.2"] # 無視される(はず)
    }

    # S3をoriginにする場合不要
    custom_header {
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/cloudfront-serve-static-website/ の
      # - 匿名 (パブリック) アクセスを許可して、ウェブサイトのエンドポイントをオリジンとして使用する
      # - アクセスが Referer ヘッダーで制限されたオリジンとして、ウェブサイトのエンドポイントを使用する
      # の節を参照
      name  = "Referer"
      value = random_id.cloudfront_referer.hex
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "for ${var.custom_domain} to S3 bucket ${aws_s3_bucket.www.id}"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  aliases = [var.custom_domain]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.www.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # viewer_protocol_policy = "allow-all"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # # Cache behavior with precedence 0
  # ordered_cache_behavior {
  #   path_pattern     = "/content/immutable/*"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = local.s3_origin_id

  #   forwarded_values {
  #     query_string = false
  #     headers      = ["Origin"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   default_ttl            = 86400
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  # # Cache behavior with precedence 1
  # ordered_cache_behavior {
  #   path_pattern     = "/content/*"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = local.s3_origin_id

  #   forwarded_values {
  #     query_string = false

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   default_ttl            = 3600
  #   max_ttl                = 86400
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # restriction_type = "whitelist"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  # tags = {
  #   Environment = "production"
  # }

  viewer_certificate {
    # cloudfront_default_certificate = true
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.www.arn
    # minimum_protocol_version       = "TLSv1.1_2016"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.www.zone_id
  name    = var.custom_domain
  type    = "CNAME"
  ttl     = 600
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]
}

output "s3wwwurl_tsl" {
  description = "URL of S3 bucket to hold website content"
  value       = "https://${var.custom_domain}/"
}
