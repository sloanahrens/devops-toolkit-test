terraform {
  backend "s3" {
    encrypt = true
    bucket = "tf-state-stellarbot-k8s-prod-us-east-2"
    dynamodb_table = "tf-state-stellarbot-k8s-prod-us-east-2"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}