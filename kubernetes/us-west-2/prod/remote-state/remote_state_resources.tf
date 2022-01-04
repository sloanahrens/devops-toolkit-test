provider "aws" {
  region = "us-west-2"
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "stellarbot-terraform-state-us-west-2-prod" {
  name = "stellarbot-terraform-state-us-west-2-prod"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-us-west-2-prod.k8s.local"
  }
}

# bucket for terraform remote state
resource "aws_s3_bucket" "stellarbot-terraform-state-us-west-2-prod" {
    bucket = "stellarbot-terraform-state-us-west-2-prod"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-us-west-2-prod.k8s.local"
    }
}