provider "aws" {
  region = "REGION"
}

# bucket for kops remote state
resource "aws_s3_bucket" "KOPS_BUCKET_NAME" {
    bucket = "KOPS_BUCKET_NAME"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote KOPS State Store for CLUSTER_NAME"
    }
}