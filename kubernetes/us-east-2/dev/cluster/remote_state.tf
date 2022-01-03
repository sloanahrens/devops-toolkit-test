terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-terraform-state-us-east-2-dev"
    dynamodb_table = "stellarbot-terraform-state-us-east-2-dev"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}