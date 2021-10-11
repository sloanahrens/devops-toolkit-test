provider "aws" {
  region = "REGION"
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "stellarbot-dynamodb-terraform-state-lock-REGION-CLUSTER_TYPE" {
  name = "stellarbot-dynamodb-terraform-state-lock-REGION-CLUSTER_TYPE"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for stellarbot-REGION-CLUSTER_TYPE.k8s.local"
  }
}

# bucket for terraform remote stae
resource "aws_s3_bucket" "stellarbot-terraform-state-REGION-CLUSTER_TYPE" {
    bucket = "stellarbot-terraform-state-REGION-CLUSTER_TYPE"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote Terraform State Store for stellarbot-REGION-CLUSTER_TYPE.k8s.local"
    }
}

# bucket for kops remote state
resource "aws_s3_bucket" "stellarbot-kops-state-REGION-CLUSTER_TYPE" {
    bucket = "stellarbot-kops-state-REGION-CLUSTER_TYPE"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote KOPS State Store for stellarbot-REGION-CLUSTER_TYPE.k8s.local"
    }
}