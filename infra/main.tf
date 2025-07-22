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

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  tags   = {
    Name = "My bucket"
    Environment = "Dev"
  }
}
