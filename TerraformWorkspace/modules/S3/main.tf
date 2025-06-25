provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  
}

resource "aws_s3_bucket" "terraform_lock" {
  bucket = "tfbackend-${lower(var.bucket_name)}"

  lifecycle {
    prevent_destroy = true
  }
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_lock.id
}