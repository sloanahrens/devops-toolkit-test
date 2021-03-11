terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-production-terraform-state-storage-us-east-2"
    dynamodb_table = "stellarbot-production-dynamodb-terraform-state-lock-us-east-2"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}