# outputs
output "legacy_web_server_ip" {
  value = aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION.public_ip
}
output "legacy_web_server_public_dns" {
  value = aws_route53_record.legacy-web-public-REGION-DEPLOYMENT_TYPE.fqdn
}

# web app instance
resource "aws_instance" "legacy_web_server-DEPLOYMENT_TYPE-REGION" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "r5.large"
  availability_zone           = "REGIONa"
  vpc_security_group_ids      = ["${aws_security_group.legacy_web_server_sg-DEPLOYMENT_TYPE-REGION.id}"]
  subnet_id                   = aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id
  associate_public_ip_address = true
  key_name                    = "AWS_KEY_NAME"
  tags = {
    "Name" = "stellarbot Legacy Web Server DEPLOYMENT_TYPE-REGION"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
    delete_on_termination = false
  }
}

# resource "aws_autoscaling_group" "nodes-stellarbot-dev-us-east-2" {
#   enabled_metrics      = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
#   launch_configuration = aws_launch_configuration.nodes-stellarbot-dev-us-east-2.id
#   max_size             = 1
#   metrics_granularity  = "1Minute"
#   min_size             = 1
#   name                 = "nodes.stellarbot-dev-us-east-2"
#   tag {
#     key                 = "Name"
#     propagate_at_launch = true
#     value               = "nodes.stellarbot-dev-us-east-2"
#   }
#   vpc_zone_identifier = [aws_subnet.us-east-2a-stellarbot-dev-us-east-2.id]
# }

# resource "aws_elb" "stellarbot-dev-us-east-2" {
#   cross_zone_load_balancing = false
#   health_check {
#     healthy_threshold   = 2
#     interval            = 10
#     target              = "SSL:443"
#     timeout             = 5
#     unhealthy_threshold = 2
#   }
#   idle_timeout = 300
#   listener {
#     instance_port      = 443
#     instance_protocol  = "TCP"
#     lb_port            = 443
#     lb_protocol        = "TCP"
#     ssl_certificate_id = ""
#   }
#   name            = "api-stellarbot-dev-us-eas-73u75n"
#   security_groups = [aws_security_group.api-elb-stellarbot-dev-us-east-2.id]
#   subnets         = [aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2.id]
#   tags = {
#     "Name"                                                     = "api.stellarbot-dev-us-east-2"
#   }
# }

# resource "aws_launch_configuration" "nodes-stellarbot-dev-us-east-2" {
#   associate_public_ip_address = true
#   enable_monitoring           = false
#   image_id                    = data.aws_ami.ubuntu.id
#   instance_type               = "r5.large"
#   key_name                    = "AWS_KEY_NAME"
#   lifecycle {
#     create_before_destroy = true
#   }
#   name_prefix = "nodes.stellarbot-dev-us-east-2-"
#   root_block_device {
#     delete_on_termination = true
#     volume_size           = 128
#     volume_type           = "gp2"
#   }
#   security_groups = [aws_security_group.nodes-stellarbot-dev-us-east-2.id]
#   user_data       = file("${path.module}/data/aws_launch_configuration_nodes.stellarbot-dev-us-east-2_user_data")
# }

# app instance public DNS (main)
resource "aws_route53_record" "legacy-web-public-REGION-DEPLOYMENT_TYPE" {
  zone_id     = "R53_ZONE"
  name        = "legacy-DEPLOYMENT_TYPE-REGION"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION.public_dns}"]
}

# legacy app security group
resource "aws_security_group" "legacy_web_server_sg-DEPLOYMENT_TYPE-REGION" {
  name        = "legacy_web_server_sg-DEPLOYMENT_TYPE-REGION"
  description = "Security Group for Portal legacy_web_server-DEPLOYMENT_TYPE-REGION"
  vpc_id      = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id

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
