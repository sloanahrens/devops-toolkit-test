terraform {
  backend "s3" {
    encrypt = true
    bucket = "stellarbot-terraform-state-REGION-CLUSTER_TYPE"
    dynamodb_table = "stellarbot-dynamodb-terraform-state-lock-REGION-CLUSTER_TYPE"
    region = "REGION"
    key = "terraform.tfstate"
  }
}