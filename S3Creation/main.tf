provider "aws" {
  region = "us-east-1"
}

variable "project_name" {
}

module "s3_bucket_1" {
  source = "../TerraformWorkspace/modules/S3"
  bucket_name = var.project_name
}

