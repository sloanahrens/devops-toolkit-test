provider "aws" {
  region = "REGION"
}

resource "aws_vpc" "DEPLOYMENT_NAME" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC for DEPLOYMENT_NAME"
  }
}

#### app-subnets
resource "aws_subnet" "DEPLOYMENT_NAME_public_a" {
  vpc_id     = aws_vpc.DEPLOYMENT_NAME.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "REGIONa"

  tags = {
    Name = "Public Subnet DEPLOYMENT_NAME_public_a"
  }
}

resource "aws_subnet" "DEPLOYMENT_NAME_public_b" {
  vpc_id     = aws_vpc.DEPLOYMENT_NAME.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "REGIONb"

  tags = {
    Name = "Public Subnet DEPLOYMENT_NAME_public_b"
  }
}
#####

##### utility subnets
resource "aws_subnet" "utility-k8s-REGIONa-DEPLOYMENT_NAME" {
  availability_zone = "REGIONa"
  cidr_block        = "10.0.2.0/24"
  tags = {
    "KubernetesCluster"                                             = "K8S_CLUSTER_NAME"
    "Name"                                                          = "utility-REGIONa.K8S_CLUSTER_NAME"
    "SubnetType"                                                    = "Utility"
    "kubernetes.io/cluster/K8S_CLUSTER_NAME" = "owned"
    "kubernetes.io/role/elb"                                        = "1"
  }
  vpc_id = aws_vpc.DEPLOYMENT_NAME.id
}

resource "aws_subnet" "utility-k8s-REGIONb-DEPLOYMENT_NAME" {
  availability_zone = "REGIONb"
  cidr_block        = "10.0.3.0/24"
  tags = {
    "KubernetesCluster"                                             = "K8S_CLUSTER_NAME"
    "Name"                                                          = "utility-REGIONb.K8S_CLUSTER_NAME"
    "SubnetType"                                                    = "Utility"
    "kubernetes.io/cluster/K8S_CLUSTER_NAME" = "owned"
    "kubernetes.io/role/elb"                                        = "1"
  }
  vpc_id = aws_vpc.DEPLOYMENT_NAME.id
}
#####

resource "aws_internet_gateway" "DEPLOYMENT_NAME_ig" {
  vpc_id = aws_vpc.DEPLOYMENT_NAME.id

  tags = {
    Name = "Internet Gateway for DEPLOYMENT_NAME"
  }
}

resource "aws_route_table" "DEPLOYMENT_NAME_public" {
    vpc_id = aws_vpc.DEPLOYMENT_NAME.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.DEPLOYMENT_NAME_ig.id
    }

    tags = {
        Name = "Public Subnets Route Table for DEPLOYMENT_NAME"
    }
}

resource "aws_route_table_association" "DEPLOYMENT_NAME_public_a" {
    subnet_id = aws_subnet.DEPLOYMENT_NAME_public_a.id
    route_table_id = aws_route_table.DEPLOYMENT_NAME_public.id
}

resource "aws_route_table_association" "DEPLOYMENT_NAME_public_b" {
    subnet_id = aws_subnet.DEPLOYMENT_NAME_public_b.id
    route_table_id = aws_route_table.DEPLOYMENT_NAME_public.id
}

#####

resource "aws_security_group" "DEPLOYMENT_NAME_web_sg" {
  name        = "DEPLOYMENT_NAME_web_sg"
  description = "Allow inbound connections on port 9999"
  vpc_id = aws_vpc.DEPLOYMENT_NAME.id

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
    Name = "Security Group for Web, DEPLOYMENT_NAME"
  }
}

#####

resource "aws_launch_configuration" "DEPLOYMENT_NAME_web_lc" {

  # force a new LC on every terraform apply execution, forcing new instance(s), 
  # so we can be sure the latest master docker images are deployed
  name_prefix = "RANDOMSTR_"

  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.small"
  key_name = "AWS_KEY_NAME"

  security_groups = [ aws_security_group.DEPLOYMENT_NAME_web_sg.id ]
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
echo "POSTGRES_HOST=POSTGRESHOST" > /home/ec2-user/stack-config.sh
echo "POSTGRES_PORT=POSTGRESPORT" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_USER=POSTGRESUSER" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_PASSWORD=POSTGRESPASSWORD" >> /home/ec2-user/stack-config.sh
echo "POSTGRES_DB=POSTGRESDB" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_HOST=RABBITMQHOST" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_PORT=RABBITMQPORT" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_USER=RABBITMQDEFAULTUSER" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_PASS=RABBITMQDEFAULTPASS" >> /home/ec2-user/stack-config.sh
echo "RABBITMQ_DEFAULT_VHOST=POSTGRESUSER" >> /home/ec2-user/stack-config.sh
echo "REDIS_HOST=REDISHOST" >> /home/ec2-user/stack-config.sh
echo "REDIS_PORT=REDISPORT" >> /home/ec2-user/stack-config.sh
echo "REDIS_NAMESPACE=REDISNAMESPACE" >> /home/ec2-user/stack-config.sh
echo "SUPERUSER_PASSWORD=SUPERUSERPASSWORD" >> /home/ec2-user/stack-config.sh
echo "TESTERUSER_PASSWORD=TESTERUSERPASSWORD" >> /home/ec2-user/stack-config.sh
echo "VIEWERUSER_PASSWORD=VIEWERUSERPASSWORD" >> /home/ec2-user/stack-config.sh
export AWS_ACCESS_KEY_ID=AWSACCESSKEYID
export AWS_SECRET_ACCESS_KEY=AWSSECRETACCESSKEY
aws s3 cp s3://TERRAFORM_BUCKET_NAME/docker-compose.yaml /home/ec2-user/docker-compose.yaml
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


resource "aws_security_group" "DEPLOYMENT_NAME_elb_sg" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer for DEPLOYMENT_NAME"
  vpc_id = aws_vpc.DEPLOYMENT_NAME.id

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
    Name = "Allow HTTP through ELB Security Group for DEPLOYMENT_NAME"
  }
}

resource "aws_elb" "DEPLOYMENT_NAME_web_elb" {
  name = "web-elb"
  security_groups = [
    aws_security_group.DEPLOYMENT_NAME_elb_sg.id
  ]
  subnets = [
    aws_subnet.DEPLOYMENT_NAME_public_a.id,
    aws_subnet.DEPLOYMENT_NAME_public_b.id
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
    ssl_certificate_id   = "SSL_CERT_ARN"
  }

}

#####

resource "aws_autoscaling_group" "DEPLOYMENT_NAME_web_asg" {

  # force a new LC on every deployment, so we can be sure the latest master docker images are deployed
  name_prefix = "${aws_launch_configuration.DEPLOYMENT_NAME_web_lc.name}__"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  
  health_check_type    = "ELB"
  # TODO: change this back!
  health_check_grace_period = 3000
  # health_check_grace_period = 300

  load_balancers = [
    aws_elb.DEPLOYMENT_NAME_web_elb.id
  ]

  launch_configuration = aws_launch_configuration.DEPLOYMENT_NAME_web_lc.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.DEPLOYMENT_NAME_public_a.id,
    aws_subnet.DEPLOYMENT_NAME_public_b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Docker-compose stack instance for DEPLOYMENT_NAME"
    propagate_at_launch = true
  }

}

#####

resource "aws_route53_record" "legacy-web-public-DEPLOYMENT_NAME" {
  zone_id     = "R53_HOSTED_ZONE"
  name        = "PROJECT_NAME"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_elb.DEPLOYMENT_NAME_web_elb.dns_name}"]
}

#####

output "elb_dns_name" {
  value = aws_elb.DEPLOYMENT_NAME_web_elb.dns_name
}

output "stack_endpoint" {
  value = aws_route53_record.legacy-web-public-DEPLOYMENT_NAME.fqdn
}

output "vpc_id" {
  value = aws_vpc.DEPLOYMENT_NAME.id
}

output "public_subnet_a_id" {
  value = aws_subnet.DEPLOYMENT_NAME_public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.DEPLOYMENT_NAME_public_b.id
}

output "utility_subnet_a_id" {
  value = aws_subnet.utility-k8s-REGIONa-DEPLOYMENT_NAME.id
}

output "utility_subnet_b_id" {
  value = aws_subnet.utility-k8s-REGIONb-DEPLOYMENT_NAME.id
}