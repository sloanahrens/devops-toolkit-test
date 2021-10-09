resource "random_string" "random" {
  length           = 16
  special          = false
}

provider "aws" {
  region = "REGION"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "stellarbot Legacy-EC2 deployment VPC"
  }
}

resource "aws_subnet" "public_DEPLOYMENT_TYPE-REGIONa" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "REGIONa"

  tags = {
    Name = "Public Subnet DEPLOYMENT_TYPE-REGIONa"
  }
}

resource "aws_subnet" "public_DEPLOYMENT_TYPE-REGIONb" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "REGIONb"

  tags = {
    Name = "Public Subnet DEPLOYMENT_TYPE-REGIONb"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_public" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnets Route Table for My VPC"
    }
}

resource "aws_route_table_association" "my_vpc_DEPLOYMENT_TYPE-REGIONa_public" {
    subnet_id = aws_subnet.public_DEPLOYMENT_TYPE-REGIONa.id
    route_table_id = aws_route_table.my_vpc_public.id
}

resource "aws_route_table_association" "my_vpc_DEPLOYMENT_TYPE-REGIONb_public" {
    subnet_id = aws_subnet.public_DEPLOYMENT_TYPE-REGIONb.id
    route_table_id = aws_route_table.my_vpc_public.id
}

#####

resource "aws_security_group" "web_instance_sg" {
  name        = "web_instance_sg"
  description = "Allow inbound connections on port 9999"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access but only via LB
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group for Web App instances"
  }
}

#####

resource "aws_launch_configuration" "web" {

  # force a new LC on every terraform apply execution, forcing new instance(s), so we can be sure the latest master docker images are deployed
  name_prefix = "lc-RANDOMSTR-"

  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = "r5.large"
  key_name = "AWS_KEY_NAME"

  security_groups = [ aws_security_group.web_instance_sg.id ]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sleep 15
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
$(aws ecr get-login --no-include-email --region us-east-2)
aws s3 cp s3://stellarbot-legacy-DEPLOYMENT_TYPE-terraform-state-storage-REGION/docker-compose.yaml /home/ec2-user/docker-compose.yaml
aws s3 cp s3://stellarbot-legacy-DEPLOYMENT_TYPE-terraform-state-storage-REGION/stack-config.yaml /home/ec2-user/stack-config.yaml
echo "echo \"run 'docker ps' or 'docker logs master_prod_webapp' or 'docker logs master_prod_worker'\"" >> /home/ec2-user/.bashrc
docker --version
docker-compose --version
docker-compose -f /home/ec2-user/docker-compose.yaml up -d
echo "hello! user_data script completed."
EOF

  lifecycle {
    create_before_destroy = true
  }
}


# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#####

resource "aws_security_group" "elb_sg" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.my_vpc.id

  # SSH access but only via LB
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

resource "aws_elb" "web_elb" {
  name = "web-elb"
  security_groups = [
    aws_security_group.elb_sg.id
  ]
  subnets = [
    aws_subnet.public_DEPLOYMENT_TYPE-REGIONa.id,
    aws_subnet.public_DEPLOYMENT_TYPE-REGIONb.id
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:9999/hello"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = "9999"
    instance_protocol = "http"
    ssl_certificate_id   = aws_acm_certificate.cert.id
  }

}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.stellarbotdev.com"
  validation_method = "DNS"

  tags = {
    Environment = "all"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#####

resource "aws_autoscaling_group" "web" {

  # force a new LC on every deployment, so we can be sure the latest master docker images are deployed
  name_prefix = "${aws_launch_configuration.web.name}-asg-"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  
  health_check_type    = "ELB"
  # TODO: change this back!
  health_check_grace_period = 3000
  # health_check_grace_period = 300

  load_balancers = [
    aws_elb.web_elb.id
  ]

  launch_configuration = aws_launch_configuration.web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.public_DEPLOYMENT_TYPE-REGIONa.id,
    aws_subnet.public_DEPLOYMENT_TYPE-REGIONb.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

}

#####

resource "aws_route53_record" "legacy-web-public-REGION-DEPLOYMENT_TYPE" {
  zone_id     = "R53_ZONE"
  name        = "master"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_elb.web_elb.dns_name}"]
}

#####

output "elb_dns_name" {
  value = aws_elb.web_elb.dns_name
}

output "stack_endpoint" {
  value = aws_route53_record.legacy-web-public-REGION-DEPLOYMENT_TYPE.fqdn
}

# #####

# resource "aws_autoscaling_policy" "web_policy_up" {
#   name = "web_policy_up"
#   scaling_adjustment = 1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }

# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
#   alarm_name = "web_cpu_alarm_up"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods = "2"
#   metric_name = "CPUUtilization"
#   namespace = "AWS/EC2"
#   period = "120"
#   statistic = "Average"
#   threshold = "60"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web.name
#   }

#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions = [ aws_autoscaling_policy.web_policy_up.arn ]
# }

# # #####

# resource "aws_autoscaling_policy" "web_policy_down" {
#   name = "web_policy_down"
#   scaling_adjustment = -1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }

# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
#   alarm_name = "web_cpu_alarm_down"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods = "2"
#   metric_name = "CPUUtilization"
#   namespace = "AWS/EC2"
#   period = "120"
#   statistic = "Average"
#   threshold = "10"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web.name
#   }

#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions = [ aws_autoscaling_policy.web_policy_down.arn ]
# }

# #####

# https://hands-on.cloud/terraform-recipe-managing-auto-scaling-groups-and-load-balancers/