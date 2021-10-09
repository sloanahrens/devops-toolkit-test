provider "aws" {
  region = "REGION"
}

resource "aws_s3_bucket" "stellarbot-legacy-DEPLOYMENT_TYPE-terraform-state-storage-REGION" {
    bucket = "stellarbot-legacy-DEPLOYMENT_TYPE-terraform-state-storage-REGION"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-DEPLOYMENT_TYPE REGION"
    }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "stellarbot-legacy-DEPLOYMENT_TYPE-dynamodb-terraform-state-lock-REGION" {
  name = "stellarbot-legacy-DEPLOYMENT_TYPE-dynamodb-terraform-state-lock-REGION"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-legacy-DEPLOYMENT_TYPE REGION"
  }
}