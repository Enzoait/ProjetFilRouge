resource "aws_ecr_repository" "frontend" {
  name = "projetfilrouge-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name = "projetfilrouge-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_s3_bucket" "example" {
#   bucket = var.bucket_name
#   tags   = {
#     Name = "My bucket"
#     Environment = "Dev"
#   }
# }

resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_name}"

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_content_public" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.allow_content_public.json
}

data "aws_iam_policy_document" "allow_content_public" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}

resource "null_resource" "sync_website_files" {
  triggers = {
    source_hash = sha256(join("", fileset(replace(var.sync_directories[0].local_source_directory, "\\", "/"), "**")))
  }

  provisioner "local-exec" {
    command = <<EOT
      aws s3 sync ${var.sync_directories[0].local_source_directory} s3://${aws_s3_bucket.main.id}/${var.sync_directories[0].s3_target_directory} --delete
    EOT
  }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac"
  description                       = "OAC for S3 static website"
  origin_access_control_origin_type  = "s3"
  signing_behavior                  = "never"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website.domain_name
  description = "The domain name of the CloudFront distribution"
}
