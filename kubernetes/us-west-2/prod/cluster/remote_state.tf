terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-terraform-state-us-west-2-prod"
    dynamodb_table = "stellarbot-terraform-state-us-west-2-prod"
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}