variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default = "iimtib62673"
}

variable "tags" {
  type = object({
    Name = string
    Environment = string
  })
  default = {
    Name = "My bucket"
    Environment = "Dev"
  }
}