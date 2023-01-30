provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "stellarbot-legacy-prod-us-east-2" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC for stellarbot-legacy-prod-us-east-2"
  }
}

#### app-subnets
resource "aws_subnet" "stellarbot-legacy-prod-us-east-2_public_a" {
  vpc_id     = aws_vpc.stellarbot-legacy-prod-us-east-2.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Public Subnet stellarbot-legacy-prod-us-east-2_public_a"
  }
}

resource "aws_subnet" "stellarbot-legacy-prod-us-east-2_public_b" {
  vpc_id     = aws_vpc.stellarbot-legacy-prod-us-east-2.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Public Subnet stellarbot-legacy-prod-us-east-2_public_b"
  }
}
#####

##### utility subnets
resource "aws_subnet" "utility-k8s-us-east-2a-stellarbot-legacy-prod-us-east-2" {
  availability_zone = "us-east-2a"
  cidr_block        = "10.0.2.0/24"
  tags = {
    "KubernetesCluster"                                             = ""
    "Name"                                                          = "utility-us-east-2a."
    "SubnetType"                                                    = "Utility"
    "kubernetes.io/cluster/" = "owned"
    "kubernetes.io/role/elb"                                        = "1"
  }
  vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id
}

resource "aws_subnet" "utility-k8s-us-east-2b-stellarbot-legacy-prod-us-east-2" {
  availability_zone = "us-east-2b"
  cidr_block        = "10.0.3.0/24"
  tags = {
    "KubernetesCluster"                                             = ""
    "Name"                                                          = "utility-us-east-2b."
    "SubnetType"                                                    = "Utility"
    "kubernetes.io/cluster/" = "owned"
    "kubernetes.io/role/elb"                                        = "1"
  }
  vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id
}
#####

resource "aws_internet_gateway" "stellarbot-legacy-prod-us-east-2_ig" {
  vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id

  tags = {
    Name = "Internet Gateway for stellarbot-legacy-prod-us-east-2"
  }
}

resource "aws_route_table" "stellarbot-legacy-prod-us-east-2_public" {
    vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.stellarbot-legacy-prod-us-east-2_ig.id
    }

    tags = {
        Name = "Public Subnets Route Table for stellarbot-legacy-prod-us-east-2"
    }
}

resource "aws_route_table_association" "stellarbot-legacy-prod-us-east-2_public_a" {
    subnet_id = aws_subnet.stellarbot-legacy-prod-us-east-2_public_a.id
    route_table_id = aws_route_table.stellarbot-legacy-prod-us-east-2_public.id
}

resource "aws_route_table_association" "stellarbot-legacy-prod-us-east-2_public_b" {
    subnet_id = aws_subnet.stellarbot-legacy-prod-us-east-2_public_b.id
    route_table_id = aws_route_table.stellarbot-legacy-prod-us-east-2_public.id
}

#####

resource "aws_security_group" "stellarbot-legacy-prod-us-east-2_web_sg" {
  name        = "stellarbot-legacy-prod-us-east-2_web_sg"
  description = "Allow inbound connections on port 9999"
  vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id

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
    Name = "Security Group for Web, stellarbot-legacy-prod-us-east-2"
  }
}

#####

resource "aws_launch_configuration" "stellarbot-legacy-prod-us-east-2_web_lc" {

  # force a new LC on every terraform apply execution, forcing new instance(s), 
  # so we can be sure the latest master docker images are deployed
  name_prefix = "******_"

  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.medium"
  key_name = "stellarbot-legacy-prod-us-east-2"

  security_groups = [ aws_security_group.stellarbot-legacy-prod-us-east-2_web_sg.id ]
  # TODO: SSH via LB
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sleep 60
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin
echo "POSTGRES_HOST=postgres-primary.stellarbot-legacy-prod-us-east-2.net" > /home/ec2-user/stack-config.sh
echo "POSTGRES_PORT=5432" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_USER=stellarbot" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_PASSWORD=****************" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_DB=stellarbot_db" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_HOST=queue" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_PORT=5672" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_USER=legacy_user" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_PASS=****************" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_VHOST=stellarbot" >> /home/ec2-user/stack-config.sh
echo "REDIS_HOST=redis" >> /home/ec2-user/stack-config.sh
echo "REDIS_PORT=6379" >> /home/ec2-user/stack-config.sh
echo "REDIS_NAMESPACE='0'" >> /home/ec2-user/stack-config.sh
echo "SUPERUSER_PASSWORD=****************" >> /home/ec2-user/stack-config.sh
echo "TESTERUSER_PASSWORD=****************" >> /home/ec2-user/stack-config.sh
echo "VIEWERUSER_PASSWORD=****************" >> /home/ec2-user/stack-config.sh
export AWS_ACCESS_KEY_ID=****************
export AWS_SECRET_ACCESS_KEY=****************
aws s3 cp s3://tf-state-stellarbot-legacy-prod-us-east-2/docker-compose.yaml /home/ec2-user/docker-compose.yaml
$(aws ecr get-login --no-include-email --region us-east-2)
docker --version
docker-compose --version
docker-compose -f /home/ec2-user/docker-compose.yaml up -d
echo "Hello! user_data script completed as $(whoami)."
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


resource "aws_security_group" "stellarbot-legacy-prod-us-east-2_elb_sg" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer for stellarbot-legacy-prod-us-east-2"
  vpc_id = aws_vpc.stellarbot-legacy-prod-us-east-2.id

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
    Name = "Allow HTTP through ELB Security Group for stellarbot-legacy-prod-us-east-2"
  }
}

resource "aws_elb" "stellarbot-legacy-prod-us-east-2_web_elb" {
  name = "web-elb"
  security_groups = [
    aws_security_group.stellarbot-legacy-prod-us-east-2_elb_sg.id
  ]
  subnets = [
    aws_subnet.stellarbot-legacy-prod-us-east-2_public_a.id,
    aws_subnet.stellarbot-legacy-prod-us-east-2_public_b.id
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:9999/api/v0.1/health/app/"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = "9999"
    instance_protocol = "http"
    ssl_certificate_id   = "****************"
  }

}

#####

resource "aws_autoscaling_group" "stellarbot-legacy-prod-us-east-2_web_asg" {

  # force a new LC on every deployment, so we can be sure the latest master docker images are deployed
  name_prefix = "${aws_launch_configuration.stellarbot-legacy-prod-us-east-2_web_lc.name}__"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  
  health_check_type    = "ELB"
  # TODO: change this back!
  health_check_grace_period = 3000
  # health_check_grace_period = 300

  load_balancers = [
    aws_elb.stellarbot-legacy-prod-us-east-2_web_elb.id
  ]

  launch_configuration = aws_launch_configuration.stellarbot-legacy-prod-us-east-2_web_lc.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.stellarbot-legacy-prod-us-east-2_public_a.id,
    aws_subnet.stellarbot-legacy-prod-us-east-2_public_b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Docker-compose stack instance for stellarbot-legacy-prod-us-east-2"
    propagate_at_launch = true
  }

}

#####

resource "aws_route53_record" "legacy-web-public-stellarbot-legacy-prod-us-east-2" {
  zone_id     = "Z1F8U0P3JLBR43"
  name        = "stellarbot"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_elb.stellarbot-legacy-prod-us-east-2_web_elb.dns_name}"]
}

#####

output "elb_dns_name" {
  value = aws_elb.stellarbot-legacy-prod-us-east-2_web_elb.dns_name
}

output "stack_endpoint" {
  value = aws_route53_record.legacy-web-public-stellarbot-legacy-prod-us-east-2.fqdn
}

output "vpc_id" {
  value = aws_vpc.stellarbot-legacy-prod-us-east-2.id
}

output "public_subnet_a_id" {
  value = aws_subnet.stellarbot-legacy-prod-us-east-2_public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.stellarbot-legacy-prod-us-east-2_public_b.id
}

output "utility_subnet_a_id" {
  value = aws_subnet.utility-k8s-us-east-2a-stellarbot-legacy-prod-us-east-2.id
}

output "utility_subnet_b_id" {
  value = aws_subnet.utility-k8s-us-east-2b-stellarbot-legacy-prod-us-east-2.id
}