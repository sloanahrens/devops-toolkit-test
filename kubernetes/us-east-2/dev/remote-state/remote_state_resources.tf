provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "stellarbot-dev-terraform-state-storage-us-east-2" {
    bucket = "stellarbot-dev-terraform-state-storage-us-east-2"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-dev us-east-2"
    }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "stellarbot-dev-dynamodb-terraform-state-lock-us-east-2" {
  name = "stellarbot-dev-dynamodb-terraform-state-lock-us-east-2"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-dev us-east-2"
  }
}