# rds postgres instance
resource "aws_db_instance" "rds-postgres-REGION-DEPLOYMENT_TYPE-primary" {
   identifier                = "primary-postgres-REGION-DEPLOYMENT_TYPE"
   allocated_storage         = 15
   storage_type              = "standard"
   engine                    = "postgres"
   engine_version            = "9.6.11"
   instance_class            = "db.t2.small"
   name                      = "stellarbotdb"
   username                  = "stellarbot"
   password                  = "deal-gridlock-overlook-beckon-tout-tulip-environ-overstep"
   port                      = 5432
   publicly_accessible       = false
   vpc_security_group_ids      = ["${aws_security_group.rds_postgres_sg-DEPLOYMENT_TYPE-REGION.id}"]
   db_subnet_group_name      = aws_db_subnet_group.db-REGION-DEPLOYMENT_TYPE.id
   parameter_group_name      = "default.postgres9.6"
   multi_az                  = true
   backup_retention_period   = 14
   backup_window             = "07:19-07:49"
   maintenance_window        = "mon:06:16-mon:06:46"
   final_snapshot_identifier = "primary-REGION-DEPLOYMENT_TYPE-final-snapshot-${random_string.randstr.result}"
    tags = {
      "Name" = "RDS Postgres Cluster for DEPLOYMENT_TYPE REGION primary"
      "Reach" = "Private"
    }
}

resource "aws_route53_record" "postgres-REGION-DEPLOYMENT_TYPE-primary" {
  zone_id     = aws_route53_zone.internaldb-DEPLOYMENT_TYPE-REGION.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.rds-postgres-REGION-DEPLOYMENT_TYPE-primary.address}"]
}

resource "aws_security_group" "rds_postgres_sg-DEPLOYMENT_TYPE-REGION" {
  name        = "rds_postgres_server_sg-DEPLOYMENT_TYPE-REGION"
  description = "Security Group for Postgres RDS - DEPLOYMENT_TYPE - REGION"
  vpc_id      = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "all-web-to-postgres" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.legacy_web_server_sg-DEPLOYMENT_TYPE-REGION.id
  source_security_group_id = aws_security_group.rds_postgres_sg-DEPLOYMENT_TYPE-REGION.id
  to_port                  = 5432
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "db-REGION-DEPLOYMENT_TYPE" {
    name = "db_subnet_group_for_legacy-REGION-DEPLOYMENT_TYPE"
    subnet_ids = [
      "${aws_subnet.REGIONa-stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id}",
      "${aws_subnet.REGIONb-stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id}",
      "${aws_subnet.REGIONc-stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id}"
    ]
    tags = {
      "Name" = "DB Subnet Group for DEPLOYMENT_TYPE REGION"
      "Reach" = "Private"
    }
}
resource "aws_route53_zone" "internaldb-DEPLOYMENT_TYPE-REGION" {
    name         = "db-DEPLOYMENT_TYPE-REGION.com."
    vpc {
      vpc_id     = aws_vpc.stellarbot-DEPLOYMENT_TYPE-REGION-legacy.id
    }
}
#####