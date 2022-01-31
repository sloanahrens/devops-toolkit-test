# rds postgres instance
resource "aws_db_instance" "DEPLOYMENT_NAME-postgres-primary" {
   identifier                = "DEPLOYMENT_NAME-postgres-primary"
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
   vpc_security_group_ids      = ["${aws_security_group.DEPLOYMENT_NAME_rds_postgres_sg.id}"]
   db_subnet_group_name      = aws_db_subnet_group.DEPLOYMENT_NAME_db.id
   multi_az                  = true
   skip_final_snapshot       = true
   tags = {
      "Name" = "RDS Postgres Instance for DEPLOYMENT_NAME primary"
      "Reach" = "Private"
    }
}

# rds security group
resource "aws_security_group" "DEPLOYMENT_NAME_rds_postgres_sg" {
  name        = "DEPLOYMENT_NAME_rds_postgres_sg"
  description = "Security Group for Postgres RDS - DEPLOYMENT_NAME"
  vpc_id      = aws_vpc.DEPLOYMENT_NAME.id

  ingress {
    from_port   = POSTGRES_PORT
    to_port     = POSTGRES_PORT
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "DEPLOYMENT_NAME_all_web_to_postgres" {
  from_port                = POSTGRES_PORT
  protocol                 = "tcp"
  security_group_id        = aws_security_group.DEPLOYMENT_NAME_web_sg.id
  source_security_group_id = aws_security_group.DEPLOYMENT_NAME_rds_postgres_sg.id
  to_port                  = POSTGRES_PORT
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "DEPLOYMENT_NAME_db" {
    name = "db_subnet_group_for_legacy-DEPLOYMENT_NAME"
    subnet_ids = [
      "${aws_subnet.DEPLOYMENT_NAME_public_a.id}",
      "${aws_subnet.DEPLOYMENT_NAME_public_b.id}"
    ]
    tags = {
      "Name" = "DB Subnet Group for DEPLOYMENT_NAME"
      "Reach" = "Private"
    }
}

resource "aws_route53_zone" "DEPLOYMENT_NAME_internal_db" {
    name         = "DEPLOYMENT_NAME.net."
    vpc {
      vpc_id     = aws_vpc.DEPLOYMENT_NAME.id
    }
}

resource "aws_route53_record" "DEPLOYMENT_NAME_postgres_primary" {
  zone_id     = aws_route53_zone.DEPLOYMENT_NAME_internal_db.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.DEPLOYMENT_NAME-postgres-primary.address}"]
}

#####
output "rds_security_group_id" {
  value = aws_security_group.DEPLOYMENT_NAME_rds_postgres_sg.id
}

output "rds_internal_endpoint" {
  value = aws_route53_record.DEPLOYMENT_NAME_postgres_primary.fqdn
}