terraform {
  backend "s3" {
    encrypt = true
    bucket = "tf-state-stellarbot-legacy-prod-us-east-2"
    dynamodb_table = "tf-state-stellarbot-legacy-prod-us-east-2"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}