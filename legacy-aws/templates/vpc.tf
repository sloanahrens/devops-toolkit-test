output "node_security_group_ids" {
  value = [aws_security_group.nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id]
}

output "node_subnet_ids" {
  value = [aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id, aws_subnet.REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id, aws_subnet.REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id]
}

output "region" {
  value = "REGION"
}

output "route_table_public_id" {
  value = aws_route_table.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

output "subnet_REGIONa_id" {
  value = aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

output "subnet_REGIONb_id" {
  value = aws_subnet.REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

output "subnet_REGIONc_id" {
  value = aws_subnet.REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

output "vpc_cidr_block" {
  value = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.cidr_block
}

output "vpc_id" {
  value = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

provider "aws" {
  region = "REGION"
}

resource "aws_internet_gateway" "stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  tags = {
    "Name"       = "stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_route_table_association" "REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  route_table_id = aws_route_table.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  subnet_id      = aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_route_table_association" "REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  route_table_id = aws_route_table.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  subnet_id      = aws_subnet.REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_route_table_association" "REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  route_table_id = aws_route_table.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  subnet_id      = aws_subnet.REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_route_table" "stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  tags = {
    "Name"       = "stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_route" "route-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  route_table_id         = aws_route_table.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_security_group_rule" "all-node-to-node" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group" "nodes-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  description = "Security group for nodes"
  name        = "nodes.stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  tags = {
    "Name"    = "nodes.stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_subnet" "REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  availability_zone = "REGIONa"
  cidr_block        = "150.30.32.0/19"
  tags = {
    "Name"          = "REGIONa.stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
    "SubnetType"    = "Public"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_subnet" "REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  availability_zone = "REGIONb"
  cidr_block        = "150.30.64.0/19"
  tags = {
    "Name"          = "REGIONb.stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
    "SubnetType"    = "Public"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_subnet" "REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  availability_zone = "REGIONc"
  cidr_block        = "150.30.96.0/19"
  tags = {
    "Name"          = "REGIONc.stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
    "SubnetType"    = "Public"
  }
  vpc_id = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_vpc_dhcp_options_association" "stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  dhcp_options_id = aws_vpc_dhcp_options.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
  vpc_id          = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local.id
}

resource "aws_vpc_dhcp_options" "stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    "Name"            = "stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  }
}

resource "aws_vpc" "stellarbot-DEPLOYMENT_TYPE-REGION-legacy-local" {
  cidr_block           = "150.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name"             = "stellarbot-DEPLOYMENT_TYPE-REGION.legacy.local"
  }
}

terraform {
  required_version = ">= 0.12.0"
}
