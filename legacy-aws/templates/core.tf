# outputs
output "COLOR_legacy_web_server_ip" {
  value = aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION-COLOR.public_ip
}
output "COLOR_legacy_web_server_public_dns" {
  value = aws_route53_record.legacy-web-public-REGION-DEPLOYMENT_TYPE-COLOR.fqdn
}

# web app instance
resource "aws_instance" "legacy_web_server-DEPLOYMENT_TYPE-REGION-COLOR" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "r5.large"
  availability_zone           = "REGIONa"
  vpc_security_group_ids      = ["${aws_security_group.legacy_web_server_sg-DEPLOYMENT_TYPE-REGION.id}"]
  subnet_id                   = aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  associate_public_ip_address = true
  key_name                    = "AWS_KEY_NAME"
  tags = {
    "Name" = "stellarbot Legacy Web Server DEPLOYMENT_TYPE-REGION-COLOR"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
    delete_on_termination = false
  }
}

# app instance public DNS (main)
resource "aws_route53_record" "legacy-web-public-REGION-DEPLOYMENT_TYPE-COLOR" {
  zone_id     = "R53_ZONE"
  name        = "legacy-DEPLOYMENT_TYPE-REGION-COLOR"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION-COLOR.public_dns}"]
}

# app instance public DNS (main)
resource "aws_route53_record" "legacy-web-public-REGION-DEPLOYMENT_TYPE" {
  zone_id     = "R53_ZONE"
  name        = "legacy-DEPLOYMENT_TYPE-REGION"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION-DNS_CLR.public_dns}"]
}

# legacy app security group
resource "aws_security_group" "legacy_web_server_sg-DEPLOYMENT_TYPE-REGION" {
  name        = "legacy_web_server_sg-DEPLOYMENT_TYPE-REGION"
  description = "Security Group for Portal legacy_web_server-DEPLOYMENT_TYPE-REGION"
  vpc_id      = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ami for legacy servers
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


# utility
resource "random_string" "randstr" {
  length = 8
  special = false
  upper = false
}
