resource "random_string" "random" {
  length           = 16
  special          = false
}

# rds postgres instance
resource "aws_db_instance" "rds-postgres-REGION-CLUSTER_TYPE-primary" {
   identifier                = "primary-postgres-REGION-CLUSTER_TYPE"
   allocated_storage         = 15
   storage_type              = "standard"
   engine                    = "postgres"
   engine_version            = "POSTGRES_VERSION"
   instance_class            = "RDS_INSTANCE_TYPE"
   name                      = "POSTGRES_DB"
   username                  = "POSTGRES_USER"
   password                  = "POSTGRES_PASSWORD"
   port                      = POSTGRES_PORT
   publicly_accessible       = false
   vpc_security_group_ids      = ["${aws_security_group.rds_postgres_sg-REGION-CLUSTER_TYPE.id}"]
   db_subnet_group_name      = aws_db_subnet_group.db-REGION-CLUSTER_TYPE.id
   multi_az                  = true
   backup_retention_period   = 10
   final_snapshot_identifier = "primary-REGION-CLUSTER_TYPE-final-snapshot-${random_string.random.result}"
    tags = {
      "Name" = "RDS Postgres Cluster for CLUSTER_TYPE REGION primary"
      "Reach" = "Private"
    }
}

resource "aws_security_group" "rds_postgres_sg-REGION-CLUSTER_TYPE" {
  name        = "rds_postgres_server_sg-REGION-CLUSTER_TYPE"
  description = "Security Group for Postgres RDS - CLUSTER_TYPE - REGION"
  vpc_id      = aws_vpc.PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.id

  ingress {
    from_port   = POSTGRES_PORT
    to_port     = POSTGRES_PORT
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [
        aws_subnet.REGIONa-PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.cidr_block,
        aws_subnet.REGIONb-PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.cidr_block
    ]
  }
}

resource "aws_security_group_rule" "all-nodes-to-postgres" {
  from_port                = POSTGRES_PORT
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes-PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.id
  source_security_group_id = aws_security_group.rds_postgres_sg-REGION-CLUSTER_TYPE.id
  to_port                  = POSTGRES_PORT
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "db-REGION-CLUSTER_TYPE" {
    name = "db_subnet_group_for_legacy-REGION-CLUSTER_TYPE"
    subnet_ids = [
      aws_subnet.REGIONa-PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.id,
      aws_subnet.REGIONb-PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.id
    ]
    tags = {
      "Name" = "DB Subnet Group for CLUSTER_TYPE REGION"
      "Reach" = "Private"
    }
}
resource "aws_route53_zone" "internaldb-REGION-CLUSTER_TYPE" {
    name         = "db-REGION-CLUSTER_TYPE.com."
    vpc {
      vpc_id     = aws_vpc.PROJECT_NAME-REGION-CLUSTER_TYPE-k8s-local.id
    }
}
resource "aws_route53_record" "postgres-REGION-CLUSTER_TYPE-primary" {
  zone_id     = aws_route53_zone.internaldb-REGION-CLUSTER_TYPE.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.rds-postgres-REGION-CLUSTER_TYPE-primary.address}"]
}
#####

output "rds_internal_endpoint" {
  value = aws_route53_record.postgres-REGION-CLUSTER_TYPE-primary.fqdn
}
