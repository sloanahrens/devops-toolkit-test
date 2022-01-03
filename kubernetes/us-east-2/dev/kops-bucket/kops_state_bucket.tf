provider "aws" {
  region = "us-east-2"
}

# bucket for kops remote state
resource "aws_s3_bucket" "stellarbot-kops-state-us-east-2-dev" {
    bucket = "stellarbot-kops-state-us-east-2-dev"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote KOPS State Store for stellarbot-us-east-2-dev.k8s.local"
    }
}