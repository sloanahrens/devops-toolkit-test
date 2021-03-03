terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-dev-terraform-state-storage-us-east-2"
    dynamodb_table = "stellarbot-dev-dynamodb-terraform-state-lock-us-east-2"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}