resource "random_string" "random" {
  length           = 16
  special          = false
}

# rds postgres instance
resource "aws_db_instance" "rds-postgres-us-west-2-prod-primary" {
   identifier                = "primary-postgres-us-west-2-prod"
   allocated_storage         = 15
   storage_type              = "standard"
   engine                    = "postgres"
   engine_version            = "12.8"
   instance_class            = "db.t3.small"
   name                      = "stellarbotdb"
   username                  = "stellarbot"
   password                  = "motto-somehow-salad-oughtest-flip-ceremony-dump-insulin-stoke-resolute"
   port                      = 5432
   publicly_accessible       = false
   vpc_security_group_ids      = ["${aws_security_group.rds_postgres_sg-us-west-2-prod.id}"]
   db_subnet_group_name      = aws_db_subnet_group.db-us-west-2-prod.id
   multi_az                  = true
   backup_retention_period   = 10
   final_snapshot_identifier = "primary-us-west-2-prod-final-snapshot-${random_string.random.result}"
    tags = {
      "Name" = "RDS Postgres Cluster for prod us-west-2 primary"
      "Reach" = "Private"
    }
}

resource "aws_security_group" "rds_postgres_sg-us-west-2-prod" {
  name        = "rds_postgres_server_sg-us-west-2-prod"
  description = "Security Group for Postgres RDS - prod - us-west-2"
  vpc_id      = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [
        aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.cidr_block,
        aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.cidr_block
    ]
  }
}

resource "aws_security_group_rule" "all-nodes-to-postgres" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes-stellarbot-us-west-2-prod-k8s-local.id
  source_security_group_id = aws_security_group.rds_postgres_sg-us-west-2-prod.id
  to_port                  = 5432
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "db-us-west-2-prod" {
    name = "db_subnet_group_for_legacy-us-west-2-prod"
    subnet_ids = [
      aws_subnet.us-west-2a-stellarbot-us-west-2-prod-k8s-local.id,
      aws_subnet.us-west-2b-stellarbot-us-west-2-prod-k8s-local.id
    ]
    tags = {
      "Name" = "DB Subnet Group for prod us-west-2"
      "Reach" = "Private"
    }
}
resource "aws_route53_zone" "internaldb-us-west-2-prod" {
    name         = "db-us-west-2-prod.com."
    vpc {
      vpc_id     = aws_vpc.stellarbot-us-west-2-prod-k8s-local.id
    }
}
resource "aws_route53_record" "postgres-us-west-2-prod-primary" {
  zone_id     = aws_route53_zone.internaldb-us-west-2-prod.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.rds-postgres-us-west-2-prod-primary.address}"]
}
#####

output "rds_internal_endpoint" {
  value = aws_route53_record.postgres-us-west-2-prod-primary.fqdn
}
