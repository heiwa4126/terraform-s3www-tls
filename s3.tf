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

# resource "aws_s3_bucket_acl" "www" {
#   bucket = aws_s3_bucket.www.id
#   acl    = "private"
# }

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
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true # S3から直にhttp:でアクセスできない
}

# TODO: CloudFrontだとこれ不要なのでは? 確認する
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

data "aws_iam_policy_document" "www" {
  statement {
    sid       = "GetObjectFromCloudFront"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3d.iam_arn]
    }
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
  # このURLでアクセス不可
}
