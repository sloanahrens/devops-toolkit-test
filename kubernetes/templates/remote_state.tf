terraform {
  backend "s3" {
    encrypt = true
    bucket = "TERRAFORM_BUCKET_NAME"
    dynamodb_table = "TERRAFORM_DYNAMODB_TABLE_NAME"
    region = "REGION"
    key = "terraform.tfstate"
  }
}