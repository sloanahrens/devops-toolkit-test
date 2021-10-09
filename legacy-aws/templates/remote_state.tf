terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-legacy-DEPLOYMENT_TYPE-terraform-state-storage-REGION"
    dynamodb_table = "stellarbot-legacy-DEPLOYMENT_TYPE-dynamodb-terraform-state-lock-REGION"
    region = "REGION"
    key = "terraform.tfstate"
  }
}