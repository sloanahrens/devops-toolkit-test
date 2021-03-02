terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-CLUSTER_TYPE-terraform-state-storage-REGION"
    dynamodb_table = "stellarbot-CLUSTER_TYPE-dynamodb-terraform-state-lock-REGION"
    region = "REGION"
    key = "terraform.tfstate"
  }
}