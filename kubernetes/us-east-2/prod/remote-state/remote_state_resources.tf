provider "aws" {
  region = "us-east-2"
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "tf-state-stellarbot-k8s-prod-us-east-2" {
  name = "tf-state-stellarbot-k8s-prod-us-east-2"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-k8s-prod-us-east-2"
  }
}

# bucket for terraform remote state
resource "aws_s3_bucket" "tf-state-stellarbot-k8s-prod-us-east-2" {
    bucket = "tf-state-stellarbot-k8s-prod-us-east-2"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-k8s-prod-us-east-2"
    }
}