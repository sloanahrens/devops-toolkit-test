provider "aws" {
  region = "us-east-2"
}

# bucket for kops remote state
resource "aws_s3_bucket" "kops-state-stellarbot-k8s-prod-us-east-2" {
    bucket = "kops-state-stellarbot-k8s-prod-us-east-2"

    versioning {
      enabled = true
    }

    tags = {
      Name = "S3 Remote KOPS State Store for stellarbot-k8s-prod-us-east-2.k8s.local"
    }
}