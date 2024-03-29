provider "aws" {
  region = "REGION"
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "TERRAFORM_DYNAMODB_TABLE_NAME" {
  name = "TERRAFORM_DYNAMODB_TABLE_NAME"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for DEPLOYMENT_NAME"
  }
}

# # bucket for terraform remote state
# resource "aws_s3_bucket" "TERRAFORM_BUCKET_NAME" {
#     bucket = "TERRAFORM_BUCKET_NAME"

#     versioning {
#       enabled = true
#     }

#     tags = {
#       Name = "S3 Remote Terraform State Store for DEPLOYMENT_NAME"
#     }
# }


resource "aws_s3_bucket" "TERRAFORM_BUCKET_NAME" {
    bucket = "TERRAFORM_BUCKET_NAME"
}

resource "aws_s3_bucket_acl" "TERRAFORM_BUCKET_NAME_acl" {
    bucket = aws_s3_bucket.TERRAFORM_BUCKET_NAME.id
    acl    = "private"
}

resource "aws_s3_bucket_versioning" "TERRAFORM_BUCKET_NAME_versioning" {
    bucket = aws_s3_bucket.TERRAFORM_BUCKET_NAME.id
    
    versioning_configuration {
      status = "Enabled"
    }
}