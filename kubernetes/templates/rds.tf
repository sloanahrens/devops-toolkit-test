# rds postgres instance
resource "aws_db_instance" "rds-postgres-REGION-DEPLOYMENT_TYPE-primary" {
   identifier                = "primary-postgres-REGION-DEPLOYMENT_TYPE"
   allocated_storage         = 15
   storage_type              = "standard"
   engine                    = "postgres"
   engine_version            = "9.6.20"
   instance_class            = "db.m5.small"
   name                      = "PROJECT_NAME_db"
   username                  = "PROJECT_NAME"
   password                  = "deal-gridlock-overlook-beckon-tout-tulip-environ-overstep"
   port                      = 5432
   publicly_accessible       = false
   vpc_security_group_ids      = ["${aws_security_group.rds_postgres_sg-REGION-DEPLOYMENT_TYPE.id}"]
   db_subnet_group_name      = aws_db_subnet_group.db-REGION-DEPLOYMENT_TYPE.id
   parameter_group_name      = "default.postgres9.6"
   multi_az                  = true
   backup_retention_period   = 14
   backup_window             = "07:19-07:49"
   maintenance_window        = "mon:06:16-mon:06:46"
   final_snapshot_identifier = "primary-REGION-DEPLOYMENT_TYPE-final-snapshot-${random_string.random.result}"
    tags = {
      "Name" = "RDS Postgres Cluster for DEPLOYMENT_TYPE REGION primary"
      "Reach" = "Private"
    }
}

resource "aws_route53_record" "postgres-REGION-DEPLOYMENT_TYPE-primary" {
  zone_id     = aws_route53_zone.internaldb-REGION-DEPLOYMENT_TYPE.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.rds-postgres-REGION-DEPLOYMENT_TYPE-primary.address}"]
}

resource "aws_security_group" "rds_postgres_sg-REGION-DEPLOYMENT_TYPE" {
  name        = "rds_postgres_server_sg-REGION-DEPLOYMENT_TYPE"
  description = "Security Group for Postgres RDS - DEPLOYMENT_TYPE - REGION"
  vpc_id      = aws_vpc.PROJECT_NAME-REGION-DEPLOYMENT_TYPE-k8s-local.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "all-nodes-to-postgres" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes-PROJECT_NAME-REGION-DEPLOYMENT_TYPE-k8s-local.id
  source_security_group_id = aws_security_group.rds_postgres_sg-REGION-DEPLOYMENT_TYPE.id
  to_port                  = 5432
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "db-REGION-DEPLOYMENT_TYPE" {
    name = "db_subnet_group_for_legacy-REGION-DEPLOYMENT_TYPE"
    subnet_ids = [
      aws_subnet.REGIONa-PROJECT_NAME-REGION-DEPLOYMENT_TYPE-k8s-local.id
    ]
    tags = {
      "Name" = "DB Subnet Group for DEPLOYMENT_TYPE REGION"
      "Reach" = "Private"
    }
}
resource "aws_route53_zone" "internaldb-REGION-DEPLOYMENT_TYPE" {
    name         = "db-REGION-DEPLOYMENT_TYPE.com."
    vpc {
      vpc_id     = aws_vpc.PROJECT_NAME-REGION-DEPLOYMENT_TYPE-k8s-local.id
    }
}
#####

output "rds_internal_endpoint" {
  value = aws_route53_record.postgres-REGION-DEPLOYMENT_TYPE-primary.fqdn
}