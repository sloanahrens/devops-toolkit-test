provider "aws" {
  region = "us-east-2"
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "stellarbot-terraform-state-us-east-2-dev" {
  name = "stellarbot-terraform-state-us-east-2-dev"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-us-east-2-dev.k8s.local"
  }
}

# bucket for terraform remote state
resource "aws_s3_bucket" "stellarbot-terraform-state-us-east-2-dev" {
    bucket = "stellarbot-terraform-state-us-east-2-dev"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-us-east-2-dev.k8s.local"
    }
}