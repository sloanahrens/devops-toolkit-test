provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform-state-storage-us-west-2" {
    bucket = "terraform-state-storage-us-west-2"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags {
      Name = "S3 Remote Terraform State Store us-west-2"
    }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-us-west-2" {
  name = "terraform-state-lock-dynamo-us-west-2"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB Terraform State Lock Table for us-west-2"
  }
}
