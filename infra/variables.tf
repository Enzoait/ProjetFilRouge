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


variable "mime_types" {
  description = "Mapping of file extensions to their respective MIME (Multipurpose Internet Mail Extensions) types. This helps in determining the nature and format of a document."
  type        = map(string)
  default = {
    htm  = "text/html"
    html = "text/html"
    css  = "text/css"
    ttf  = "font/ttf"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
  }
}

variable "sync_directories" {
  type = list(object({
    local_source_directory = string
    s3_target_directory    = string
  }))
  description = "List of directories to synchronize with Amazon S3."
  default     = [{
  local_source_directory = "../frontend/dist"
  s3_target_directory    = ""
}]
}