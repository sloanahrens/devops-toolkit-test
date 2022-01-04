provider "aws" {
  region = "us-west-2"
}

# bucket for kops remote state
resource "aws_s3_bucket" "stellarbot-kops-state-us-west-2-prod" {
    bucket = "stellarbot-kops-state-us-west-2-prod"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote KOPS State Store for stellarbot-us-west-2-prod.k8s.local"
    }
}