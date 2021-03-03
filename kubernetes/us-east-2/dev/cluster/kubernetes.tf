locals {
  cluster_name                      = "stellarbot-dev-us-east-2.k8s.local"
  master_autoscaling_group_ids      = [aws_autoscaling_group.master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local.id]
  master_security_group_ids         = [aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id]
  masters_role_arn                  = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.arn
  masters_role_name                 = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.name
  node_autoscaling_group_ids        = [aws_autoscaling_group.nodes-stellarbot-dev-us-east-2-k8s-local.id]
  node_security_group_ids           = [aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id]
  node_subnet_ids                   = [aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id]
  nodes_role_arn                    = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.arn
  nodes_role_name                   = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.name
  region                            = "us-east-2"
  route_table_private-us-east-2a_id = aws_route_table.private-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  route_table_public_id             = aws_route_table.stellarbot-dev-us-east-2-k8s-local.id
  subnet_us-east-2a_id              = aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  subnet_utility-us-east-2a_id      = aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  vpc_cidr_block                    = aws_vpc.stellarbot-dev-us-east-2-k8s-local.cidr_block
  vpc_id                            = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

output "cluster_name" {
  value = "stellarbot-dev-us-east-2.k8s.local"
}

output "master_autoscaling_group_ids" {
  value = [aws_autoscaling_group.master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local.id]
}

output "master_security_group_ids" {
  value = [aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id]
}

output "masters_role_arn" {
  value = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.arn
}

output "masters_role_name" {
  value = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.name
}

output "node_autoscaling_group_ids" {
  value = [aws_autoscaling_group.nodes-stellarbot-dev-us-east-2-k8s-local.id]
}

output "node_security_group_ids" {
  value = [aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id]
}

output "node_subnet_ids" {
  value = [aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id]
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.arn
}

output "nodes_role_name" {
  value = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.name
}

output "region" {
  value = "us-east-2"
}

output "route_table_private-us-east-2a_id" {
  value = aws_route_table.private-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

output "route_table_public_id" {
  value = aws_route_table.stellarbot-dev-us-east-2-k8s-local.id
}

output "subnet_us-east-2a_id" {
  value = aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

output "subnet_utility-us-east-2a_id" {
  value = aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

output "vpc_cidr_block" {
  value = aws_vpc.stellarbot-dev-us-east-2-k8s-local.cidr_block
}

output "vpc_id" {
  value = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_autoscaling_attachment" "master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local" {
  autoscaling_group_name = aws_autoscaling_group.master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local.id
  elb                    = aws_elb.api-stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_autoscaling_group" "master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local" {
  enabled_metrics      = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_configuration = aws_launch_configuration.master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local.id
  max_size             = 1
  metrics_granularity  = "1Minute"
  min_size             = 1
  name                 = "master-us-east-2a.masters.stellarbot-dev-us-east-2.k8s.local"
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "stellarbot-dev-us-east-2.k8s.local"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "master-us-east-2a.masters.stellarbot-dev-us-east-2.k8s.local"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-east-2a"
  }
  tag {
    key                 = "k8s.io/role/master"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-east-2a"
  }
  tag {
    key                 = "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id]
}

resource "aws_autoscaling_group" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  enabled_metrics      = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_configuration = aws_launch_configuration.nodes-stellarbot-dev-us-east-2-k8s-local.id
  max_size             = 1
  metrics_granularity  = "1Minute"
  min_size             = 1
  name                 = "nodes.stellarbot-dev-us-east-2.k8s.local"
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "stellarbot-dev-us-east-2.k8s.local"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "nodes.stellarbot-dev-us-east-2.k8s.local"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes"
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes"
  }
  tag {
    key                 = "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id]
}

resource "aws_ebs_volume" "a-etcd-events-stellarbot-dev-us-east-2-k8s-local" {
  availability_zone = "us-east-2a"
  encrypted         = false
  size              = 20
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "a.etcd-events.stellarbot-dev-us-east-2.k8s.local"
    "k8s.io/etcd/events"                                       = "a/a"
    "k8s.io/role/master"                                       = "1"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  type = "gp2"
}

resource "aws_ebs_volume" "a-etcd-main-stellarbot-dev-us-east-2-k8s-local" {
  availability_zone = "us-east-2a"
  encrypted         = false
  size              = 20
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "a.etcd-main.stellarbot-dev-us-east-2.k8s.local"
    "k8s.io/etcd/main"                                         = "a/a"
    "k8s.io/role/master"                                       = "1"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  type = "gp2"
}

resource "aws_eip" "us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "us-east-2a.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  vpc = true
}

resource "aws_elb" "api-stellarbot-dev-us-east-2-k8s-local" {
  cross_zone_load_balancing = false
  health_check {
    healthy_threshold   = 2
    interval            = 10
    target              = "SSL:443"
    timeout             = 5
    unhealthy_threshold = 2
  }
  idle_timeout = 300
  listener {
    instance_port      = 443
    instance_protocol  = "TCP"
    lb_port            = 443
    lb_protocol        = "TCP"
    ssl_certificate_id = ""
  }
  name            = "api-stellarbot-dev-us-eas-73u75n"
  security_groups = [aws_security_group.api-elb-stellarbot-dev-us-east-2-k8s-local.id]
  subnets         = [aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id]
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "api.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-stellarbot-dev-us-east-2-k8s-local" {
  name = "masters.stellarbot-dev-us-east-2.k8s.local"
  role = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.name
}

resource "aws_iam_instance_profile" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  name = "nodes.stellarbot-dev-us-east-2.k8s.local"
  role = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.name
}

resource "aws_iam_role_policy" "masters-stellarbot-dev-us-east-2-k8s-local" {
  name   = "masters.stellarbot-dev-us-east-2.k8s.local"
  policy = file("${path.module}/data/aws_iam_role_policy_masters.stellarbot-dev-us-east-2.k8s.local_policy")
  role   = aws_iam_role.masters-stellarbot-dev-us-east-2-k8s-local.name
}

resource "aws_iam_role_policy" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  name   = "nodes.stellarbot-dev-us-east-2.k8s.local"
  policy = file("${path.module}/data/aws_iam_role_policy_nodes.stellarbot-dev-us-east-2.k8s.local_policy")
  role   = aws_iam_role.nodes-stellarbot-dev-us-east-2-k8s-local.name
}

resource "aws_iam_role" "masters-stellarbot-dev-us-east-2-k8s-local" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_masters.stellarbot-dev-us-east-2.k8s.local_policy")
  name               = "masters.stellarbot-dev-us-east-2.k8s.local"
}

resource "aws_iam_role" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_nodes.stellarbot-dev-us-east-2.k8s.local_policy")
  name               = "nodes.stellarbot-dev-us-east-2.k8s.local"
}

resource "aws_internet_gateway" "stellarbot-dev-us-east-2-k8s-local" {
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_key_pair" "kubernetes-stellarbot-dev-us-east-2-k8s-local-3c696872dda0d8c74868f68979ea2f3d" {
  key_name   = "kubernetes.stellarbot-dev-us-east-2.k8s.local-3c:69:68:72:dd:a0:d8:c7:48:68:f6:89:79:ea:2f:3d"
  public_key = file("${path.module}/data/aws_key_pair_kubernetes.stellarbot-dev-us-east-2.k8s.local-3c696872dda0d8c74868f68979ea2f3d_public_key")
}

resource "aws_launch_configuration" "master-us-east-2a-masters-stellarbot-dev-us-east-2-k8s-local" {
  associate_public_ip_address = false
  enable_monitoring           = false
  iam_instance_profile        = aws_iam_instance_profile.masters-stellarbot-dev-us-east-2-k8s-local.id
  image_id                    = "ami-0b287e7832eb862f8"
  instance_type               = "r5.xlarge"
  key_name                    = aws_key_pair.kubernetes-stellarbot-dev-us-east-2-k8s-local-3c696872dda0d8c74868f68979ea2f3d.id
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = "master-us-east-2a.masters.stellarbot-dev-us-east-2.k8s.local-"
  root_block_device {
    delete_on_termination = true
    volume_size           = 64
    volume_type           = "gp2"
  }
  security_groups = [aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id]
  user_data       = file("${path.module}/data/aws_launch_configuration_master-us-east-2a.masters.stellarbot-dev-us-east-2.k8s.local_user_data")
}

resource "aws_launch_configuration" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  associate_public_ip_address = false
  enable_monitoring           = false
  iam_instance_profile        = aws_iam_instance_profile.nodes-stellarbot-dev-us-east-2-k8s-local.id
  image_id                    = "ami-0b287e7832eb862f8"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.kubernetes-stellarbot-dev-us-east-2-k8s-local-3c696872dda0d8c74868f68979ea2f3d.id
  lifecycle {
    create_before_destroy = true
  }
  name_prefix = "nodes.stellarbot-dev-us-east-2.k8s.local-"
  root_block_device {
    delete_on_termination = true
    volume_size           = 128
    volume_type           = "gp2"
  }
  security_groups = [aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id]
  user_data       = file("${path.module}/data/aws_launch_configuration_nodes.stellarbot-dev-us-east-2.k8s.local_user_data")
}

resource "aws_nat_gateway" "us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  allocation_id = aws_eip.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  subnet_id     = aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "us-east-2a.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_route_table_association" "private-us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  route_table_id = aws_route_table.private-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  subnet_id      = aws_subnet.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_route_table_association" "utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  route_table_id = aws_route_table.stellarbot-dev-us-east-2-k8s-local.id
  subnet_id      = aws_subnet.utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_route_table" "private-us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "private-us-east-2a.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                  = "private-us-east-2a"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_route_table" "stellarbot-dev-us-east-2-k8s-local" {
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                  = "public"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_route" "route-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.stellarbot-dev-us-east-2-k8s-local.id
  route_table_id         = aws_route_table.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_route" "route-private-us-east-2a-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
  route_table_id         = aws_route_table.private-us-east-2a-stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_security_group_rule" "all-master-to-master" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "all-master-to-node" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "all-node-to-node" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "api-elb-egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.api-elb-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.api-elb-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "https-elb-to-master" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.api-elb-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "icmp-pmtu-api-elb-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3
  protocol          = "icmp"
  security_group_id = aws_security_group.api-elb-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 4
  type              = "ingress"
}

resource "aws_security_group_rule" "master-egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "node-egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  from_port                = 0
  protocol                 = "4"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  from_port                = 1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 2379
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  from_port                = 2382
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 4001
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  from_port                = 4003
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  from_port                = 1
  protocol                 = "udp"
  security_group_id        = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes-stellarbot-dev-us-east-2-k8s-local.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group" "api-elb-stellarbot-dev-us-east-2-k8s-local" {
  description = "Security group for api ELB"
  name        = "api-elb.stellarbot-dev-us-east-2.k8s.local"
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "api-elb.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_security_group" "masters-stellarbot-dev-us-east-2-k8s-local" {
  description = "Security group for masters"
  name        = "masters.stellarbot-dev-us-east-2.k8s.local"
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "masters.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_security_group" "nodes-stellarbot-dev-us-east-2-k8s-local" {
  description = "Security group for nodes"
  name        = "nodes.stellarbot-dev-us-east-2.k8s.local"
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "nodes.stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_subnet" "us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  availability_zone = "us-east-2a"
  cidr_block        = "172.20.32.0/19"
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "us-east-2a.stellarbot-dev-us-east-2.k8s.local"
    "SubnetType"                                               = "Private"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
    "kubernetes.io/role/internal-elb"                          = "1"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_subnet" "utility-us-east-2a-stellarbot-dev-us-east-2-k8s-local" {
  availability_zone = "us-east-2a"
  cidr_block        = "172.20.0.0/22"
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "utility-us-east-2a.stellarbot-dev-us-east-2.k8s.local"
    "SubnetType"                                               = "Utility"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
    "kubernetes.io/role/elb"                                   = "1"
  }
  vpc_id = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_vpc_dhcp_options_association" "stellarbot-dev-us-east-2-k8s-local" {
  dhcp_options_id = aws_vpc_dhcp_options.stellarbot-dev-us-east-2-k8s-local.id
  vpc_id          = aws_vpc.stellarbot-dev-us-east-2-k8s-local.id
}

resource "aws_vpc_dhcp_options" "stellarbot-dev-us-east-2-k8s-local" {
  domain_name         = "us-east-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_vpc" "stellarbot-dev-us-east-2-k8s-local" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "KubernetesCluster"                                        = "stellarbot-dev-us-east-2.k8s.local"
    "Name"                                                     = "stellarbot-dev-us-east-2.k8s.local"
    "kubernetes.io/cluster/stellarbot-dev-us-east-2.k8s.local" = "owned"
  }
}

terraform {
  required_version = ">= 0.12.0"
}
