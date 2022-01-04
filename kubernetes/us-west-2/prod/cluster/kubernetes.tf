locals {
  cluster_name                      = "stellarbot-us-west-2-prod.k8s.local"
  master_autoscaling_group_ids      = [aws_autoscaling_group.master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local.id]
  master_security_group_ids         = [aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id]
  masters_role_arn                  = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.arn
  masters_role_name                 = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.name
  node_autoscaling_group_ids        = [aws_autoscaling_group.nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id, aws_autoscaling_group.nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
  node_security_group_ids           = [aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id]
  node_subnet_ids                   = [aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id, aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
  nodes_role_arn                    = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.arn
  nodes_role_name                   = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.name
  region                            = "us-west-2"
  route_table_private-us-west-2a_id = aws_route_table.private-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  route_table_private-us-west-2b_id = aws_route_table.private-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  route_table_public_id             = aws_route_table.stellarbot-us-west-2-prod-k8s-local.id
  subnet_us-west-2a_id              = aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  subnet_us-west-2b_id              = aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  subnet_utility-us-west-2a_id      = aws_subnet.utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  subnet_utility-us-west-2b_id      = aws_subnet.utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  vpc_cidr_block                    = aws_vpc.stellarbot-us-west-2-prod-k8s-local.cidr_block
  vpc_id                            = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

output "cluster_name" {
  value = "stellarbot-us-west-2-prod.k8s.local"
}

output "master_autoscaling_group_ids" {
  value = [aws_autoscaling_group.master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local.id]
}

output "master_security_group_ids" {
  value = [aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id]
}

output "masters_role_arn" {
  value = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.arn
}

output "masters_role_name" {
  value = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.name
}

output "node_autoscaling_group_ids" {
  value = [aws_autoscaling_group.nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id, aws_autoscaling_group.nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
}

output "node_security_group_ids" {
  value = [aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id]
}

output "node_subnet_ids" {
  value = [aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id, aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.arn
}

output "nodes_role_name" {
  value = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.name
}

output "region" {
  value = "us-west-2"
}

output "route_table_private-us-west-2a_id" {
  value = aws_route_table.private-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

output "route_table_private-us-west-2b_id" {
  value = aws_route_table.private-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

output "route_table_public_id" {
  value = aws_route_table.stellarbot-us-west-2-prod-k8s-local.id
}

output "subnet_us-west-2a_id" {
  value = aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

output "subnet_us-west-2b_id" {
  value = aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

output "subnet_utility-us-west-2a_id" {
  value = aws_subnet.utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

output "subnet_utility-us-west-2b_id" {
  value = aws_subnet.utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

output "vpc_cidr_block" {
  value = aws_vpc.stellarbot-us-west-2-prod-k8s-local.cidr_block
}

output "vpc_id" {
  value = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_group" "master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local.id
    version = aws_launch_template.master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local.latest_version
  }
  load_balancers      = [aws_elb.api-stellarbot-us-west-2-prod-k8s-local.id]
  max_size            = 1
  metrics_granularity = "1Minute"
  min_size            = 1
  name                = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-west-2a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"
    propagate_at_launch = true
    value               = "master"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/master"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-us-west-2a"
  }
  tag {
    key                 = "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id]
}

resource "aws_autoscaling_group" "nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
    version = aws_launch_template.nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local.latest_version
  }
  max_size            = 1
  metrics_granularity = "1Minute"
  min_size            = 1
  name                = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"
    propagate_at_launch = true
    value               = "node"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2a"
  }
  tag {
    key                 = "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id]
}

resource "aws_autoscaling_group" "nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
    version = aws_launch_template.nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local.latest_version
  }
  max_size            = 1
  metrics_granularity = "1Minute"
  min_size            = 1
  name                = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2b"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"
    propagate_at_launch = true
    value               = "node"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-us-west-2b"
  }
  tag {
    key                 = "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
}

resource "aws_ebs_volume" "a-etcd-events-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "a.etcd-events.stellarbot-us-west-2-prod.k8s.local"
    "k8s.io/etcd/events"                                        = "a/a"
    "k8s.io/role/master"                                        = "1"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_ebs_volume" "a-etcd-main-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "a.etcd-main.stellarbot-us-west-2-prod.k8s.local"
    "k8s.io/etcd/main"                                          = "a/a"
    "k8s.io/role/master"                                        = "1"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_eip" "us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc = true
}

resource "aws_eip" "us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc = true
}

resource "aws_elb" "api-stellarbot-us-west-2-prod-k8s-local" {
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
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }
  name            = "api-stellarbot-us-west-2--1e918j"
  security_groups = [aws_security_group.api-elb-stellarbot-us-west-2-prod-k8s-local.id]
  subnets         = [aws_subnet.utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id, aws_subnet.utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id]
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "api.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-stellarbot-us-west-2-prod-k8s-local" {
  name = "masters.stellarbot-us-west-2-prod.k8s.local"
  role = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.name
}

resource "aws_iam_instance_profile" "nodes-stellarbot-us-west-2-prod-k8s-local" {
  name = "nodes.stellarbot-us-west-2-prod.k8s.local"
  role = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.name
}

resource "aws_iam_role_policy" "masters-stellarbot-us-west-2-prod-k8s-local" {
  name   = "masters.stellarbot-us-west-2-prod.k8s.local"
  policy = file("${path.module}/data/aws_iam_role_policy_masters.stellarbot-us-west-2-prod.k8s.local_policy")
  role   = aws_iam_role.masters-stellarbot-us-west-2-prod-k8s-local.name
}

resource "aws_iam_role_policy" "nodes-stellarbot-us-west-2-prod-k8s-local" {
  name   = "nodes.stellarbot-us-west-2-prod.k8s.local"
  policy = file("${path.module}/data/aws_iam_role_policy_nodes.stellarbot-us-west-2-prod.k8s.local_policy")
  role   = aws_iam_role.nodes-stellarbot-us-west-2-prod-k8s-local.name
}

resource "aws_iam_role" "masters-stellarbot-us-west-2-prod-k8s-local" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_masters.stellarbot-us-west-2-prod.k8s.local_policy")
  name               = "masters.stellarbot-us-west-2-prod.k8s.local"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "masters.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_iam_role" "nodes-stellarbot-us-west-2-prod-k8s-local" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_nodes.stellarbot-us-west-2-prod.k8s.local_policy")
  name               = "nodes.stellarbot-us-west-2-prod.k8s.local"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "nodes.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_internet_gateway" "stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_key_pair" "kubernetes-stellarbot-us-west-2-prod-k8s-local-23d70451c38feb678d68b2cafbd860be" {
  key_name   = "kubernetes.stellarbot-us-west-2-prod.k8s.local-23:d7:04:51:c3:8f:eb:67:8d:68:b2:ca:fb:d8:60:be"
  public_key = file("${path.module}/data/aws_key_pair_kubernetes.stellarbot-us-west-2-prod.k8s.local-23d70451c38feb678d68b2cafbd860be_public_key")
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_launch_template" "master-us-west-2a-masters-stellarbot-us-west-2-prod-k8s-local" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 64
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.masters-stellarbot-us-west-2-prod-k8s-local.id
  }
  image_id      = "ami-0f81e6e71078b75b6"
  instance_type = "t3.large"
  key_name      = aws_key_pair.kubernetes-stellarbot-us-west-2-prod-k8s-local-23d70451c38feb678d68b2cafbd860be.id
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }
  name = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                                   = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                                = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"             = "master-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                    = "master"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane" = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"        = ""
      "k8s.io/role/master"                                                                  = "1"
      "kops.k8s.io/instancegroup"                                                           = "master-us-west-2a"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                           = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                                   = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                                = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"             = "master-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                    = "master"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane" = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"        = ""
      "k8s.io/role/master"                                                                  = "1"
      "kops.k8s.io/instancegroup"                                                           = "master-us-west-2a"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                           = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                                   = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                                                = "master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"             = "master-us-west-2a"
    "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                    = "master"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane" = ""
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"        = ""
    "k8s.io/role/master"                                                                  = "1"
    "kops.k8s.io/instancegroup"                                                           = "master-us-west-2a"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                           = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_master-us-west-2a.masters.stellarbot-us-west-2-prod.k8s.local_user_data")
}

resource "aws_launch_template" "nodes-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-stellarbot-us-west-2-prod-k8s-local.id
  }
  image_id      = "ami-0f81e6e71078b75b6"
  instance_type = "t3.small"
  key_name      = aws_key_pair.kubernetes-stellarbot-us-west-2-prod-k8s-local-23d70451c38feb678d68b2cafbd860be.id
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }
  name = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                       = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                       = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                                       = "nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2a"
    "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2a"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_nodes-us-west-2a.stellarbot-us-west-2-prod.k8s.local_user_data")
}

resource "aws_launch_template" "nodes-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-stellarbot-us-west-2-prod-k8s-local.id
  }
  image_id      = "ami-0f81e6e71078b75b6"
  instance_type = "t3.small"
  key_name      = aws_key_pair.kubernetes-stellarbot-us-west-2-prod-k8s-local-23d70451c38feb678d68b2cafbd860be.id
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }
  name = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                       = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2b"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2b"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
      "Name"                                                                       = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2b"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2b"
      "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                                       = "nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-us-west-2b"
    "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "nodes-us-west-2b"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local"                  = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_nodes-us-west-2b.stellarbot-us-west-2-prod.k8s.local_user_data")
}

resource "aws_nat_gateway" "us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  allocation_id = aws_eip.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  subnet_id     = aws_subnet.utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_nat_gateway" "us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  allocation_id = aws_eip.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  subnet_id     = aws_subnet.utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_route_table_association" "private-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  route_table_id = aws_route_table.private-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  subnet_id      = aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table_association" "private-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  route_table_id = aws_route_table.private-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  subnet_id      = aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table_association" "utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  route_table_id = aws_route_table.stellarbot-us-west-2-prod-k8s-local.id
  subnet_id      = aws_subnet.utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table_association" "utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  route_table_id = aws_route_table.stellarbot-us-west-2-prod-k8s-local.id
  subnet_id      = aws_subnet.utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table" "private-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "private-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                   = "private-us-west-2a"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table" "private-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "private-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                   = "private-us-west-2b"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route_table" "stellarbot-us-west-2-prod-k8s-local" {
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                   = "public"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route" "route-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.stellarbot-us-west-2-prod-k8s-local.id
  route_table_id         = aws_route_table.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route" "route-private-us-west-2a-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
  route_table_id         = aws_route_table.private-us-west-2a-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_route" "route-private-us-west-2b-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
  route_table_id         = aws_route_table.private-us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-22to22-masters-stellarbot-us-west-2-prod-k8s-local" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-22to22-nodes-stellarbot-us-west-2-prod-k8s-local" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-443to443-api-elb-stellarbot-us-west-2-prod-k8s-local" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.api-elb-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "from-api-elb-stellarbot-us-west-2-prod-k8s-local-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.api-elb-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-stellarbot-us-west-2-prod-k8s-local-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-stellarbot-us-west-2-prod-k8s-local-ingress-all-0to0-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-masters-stellarbot-us-west-2-prod-k8s-local-ingress-all-0to0-nodes-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-4-0to0-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 0
  protocol                 = "4"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-all-0to0-nodes-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-tcp-1to2379-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 2379
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-tcp-2382to4000-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 2382
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 4000
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-tcp-4003to65535-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 4003
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-stellarbot-us-west-2-prod-k8s-local-ingress-udp-1to65535-masters-stellarbot-us-west-2-prod-k8s-local" {
  from_port                = 1
  protocol                 = "udp"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "https-elb-to-master" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.api-elb-stellarbot-us-west-2-prod-k8s-local.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "icmp-pmtu-api-elb-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3
  protocol          = "icmp"
  security_group_id = aws_security_group.api-elb-stellarbot-us-west-2-prod-k8s-local.id
  to_port           = 4
  type              = "ingress"
}

resource "aws_security_group" "api-elb-stellarbot-us-west-2-prod-k8s-local" {
  description = "Security group for api ELB"
  name        = "api-elb.stellarbot-us-west-2-prod.k8s.local"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "api-elb.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_security_group" "masters-stellarbot-us-west-2-prod-k8s-local" {
  description = "Security group for masters"
  name        = "masters.stellarbot-us-west-2-prod.k8s.local"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "masters.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_security_group" "nodes-stellarbot-us-west-2-prod-k8s-local" {
  description = "Security group for nodes"
  name        = "nodes.stellarbot-us-west-2-prod.k8s.local"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "nodes.stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_subnet" "us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2a"
  cidr_block        = "172.20.32.0/19"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "SubnetType"                                                = "Private"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/role/internal-elb"                           = "1"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_subnet" "us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2b"
  cidr_block        = "172.20.64.0/19"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "SubnetType"                                                = "Private"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/role/internal-elb"                           = "1"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_subnet" "utility-us-west-2a-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2a"
  cidr_block        = "172.20.0.0/22"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "utility-us-west-2a.stellarbot-us-west-2-prod.k8s.local"
    "SubnetType"                                                = "Utility"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/role/elb"                                    = "1"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_subnet" "utility-us-west-2b-stellarbot-us-west-2-prod-k8s-local" {
  availability_zone = "us-west-2b"
  cidr_block        = "172.20.4.0/22"
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "utility-us-west-2b.stellarbot-us-west-2-prod.k8s.local"
    "SubnetType"                                                = "Utility"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
    "kubernetes.io/role/elb"                                    = "1"
  }
  vpc_id = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_vpc_dhcp_options_association" "stellarbot-us-west-2-prod-k8s-local" {
  dhcp_options_id = aws_vpc_dhcp_options.stellarbot-us-west-2-prod-k8s-local.id
  vpc_id          = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
}

resource "aws_vpc_dhcp_options" "stellarbot-us-west-2-prod-k8s-local" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

resource "aws_vpc" "stellarbot-us-west-2-prod-k8s-local" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "KubernetesCluster"                                         = "stellarbot-us-west-2-prod.k8s.local"
    "Name"                                                      = "stellarbot-us-west-2-prod.k8s.local"
    "kubernetes.io/cluster/stellarbot-us-west-2-prod.k8s.local" = "owned"
  }
}

terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      "source"  = "hashicorp/aws"
      "version" = ">= 2.46.0"
    }
  }
}
