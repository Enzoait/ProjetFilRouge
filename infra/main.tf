resource "aws_ecr_repository" "frontend" {
  name = "projetfilrouge-frontend"
}

resource "aws_ecr_repository" "backend" {
  name = "projetfilrouge-backend"
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  tags   = {
    Name = "My bucket"
    Environment = "Dev"
  }
}
