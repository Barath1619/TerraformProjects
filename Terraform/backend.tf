terraform {
  backend "s3" {
    bucket = "demo-tf-statefile-xyz"
    region = "us-east-1"
    key = "tfdev/terraform.tfstate"
    # dynamodb_table = "terraform-lock"
  }
}


# resource "aws_s3_bucket" "terraform_lock_Bucket" {
#   bucket = "demo-tf-statefile-xyz"
#   lifecycle {
#     prevent_destroy = true
#   }
# }
# resource "aws_dynamodb_table" "terraform_lock" {
#     name         = "terraform-lock"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key = "LockID"
#     attribute {
#       name = "LockID"
#       type = "S"
#     }
# }