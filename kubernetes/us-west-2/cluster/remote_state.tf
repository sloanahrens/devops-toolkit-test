terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-storage-us-west-2"
    dynamodb_table = "terraform-state-lock-dynamo-us-west-2"
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}