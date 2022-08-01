# TODO: いまのところバージョニングとロギングなし
# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "www" {
  bucket = "${local.prefix}www"
}

# 自前のキーにするとお金がちょっとかかるので
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "www" {
  bucket = aws_s3_bucket.www.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACLを一切使わない。ポリシーのみで制御。最近の流行
resource "aws_s3_bucket_ownership_controls" "www" {
  bucket = aws_s3_bucket.www.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "www" {
  depends_on              = [aws_s3_bucket_policy.www]
  bucket                  = aws_s3_bucket.www.id
  block_public_acls       = true
  block_public_policy     = false  # TODO: あとでtrueにする
  ignore_public_acls      = true
  # restrict_public_buckets = true # S3から直にhttp:でアクセスできない
  restrict_public_buckets = false
}


# CloudFrontでS3をオリジンにすると、サブディレクトリのインデックスドキュメントが使えない
resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  # error_document {
  #   key = "error.html"
  # }
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "www" {
  bucket = aws_s3_bucket.www.id
  policy = data.aws_iam_policy_document.www.json
}

# S3をCloudFrontのoriginにする場合
# data "aws_iam_policy_document" "www" {
#   statement {
#     sid       = "GetObjectFromCloudFront"
#     effect    = "Allow"
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.www.arn}/*"]
#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.s3d.iam_arn]
#     }
#   }
# }


data "aws_iam_policy_document" "www" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    # TODO:あとでコンディションを追加する
  }
}


resource "aws_s3_object" "www" {
  for_each = fileset("${path.root}/contents", "**/*")

  bucket = aws_s3_bucket.www.id
  key    = each.value
  source = "${path.root}/contents/${each.value}"

  etag         = filemd5("${path.root}/contents/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
  # acl        = "public-read"  # ACLを使わないことにしたので設定不可
}

#--------
output "s3wwwurl" {
  description = "URL of S3 bucket to hold website content"
  value       = "http://${aws_s3_bucket_website_configuration.www.website_endpoint}/"
  # CloudForntでヘッダをつけて、最終的にはこのURLでアクセス不可にする
}
output "objecturl" {
  value = "https://${aws_s3_bucket.www.bucket_regional_domain_name}/index.html"
  # こちらも↑と同様
}
