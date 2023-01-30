# rds postgres instance
resource "aws_db_instance" "stellarbot-legacy-prod-us-east-2-postgres-primary" {
   identifier                = "stellarbot-legacy-prod-us-east-2-postgres-primary"
   allocated_storage         = 15
   storage_type              = "standard"
   engine                    = "postgres"
   engine_version            = "12.8"
   instance_class            = "db.t3.small"
   db_name                   = "stellarbot_db"
   username                  = "stellarbot"
   password                  = "****************"
   port                      = 5432
   publicly_accessible       = false
   vpc_security_group_ids      = ["${aws_security_group.stellarbot-legacy-prod-us-east-2_rds_postgres_sg.id}"]
   db_subnet_group_name      = aws_db_subnet_group.stellarbot-legacy-prod-us-east-2_db.id
   multi_az                  = true
   skip_final_snapshot       = true
   tags = {
      "Name" = "RDS Postgres Instance for stellarbot-legacy-prod-us-east-2 primary"
      "Reach" = "Private"
    }
}

# rds security group
resource "aws_security_group" "stellarbot-legacy-prod-us-east-2_rds_postgres_sg" {
  name        = "stellarbot-legacy-prod-us-east-2_rds_postgres_sg"
  description = "Security Group for Postgres RDS - stellarbot-legacy-prod-us-east-2"
  vpc_id      = aws_vpc.stellarbot-legacy-prod-us-east-2.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "stellarbot-legacy-prod-us-east-2_all_web_to_postgres" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.stellarbot-legacy-prod-us-east-2_web_sg.id
  source_security_group_id = aws_security_group.stellarbot-legacy-prod-us-east-2_rds_postgres_sg.id
  to_port                  = 5432
  type                     = "ingress"
}

# networking
resource "aws_db_subnet_group" "stellarbot-legacy-prod-us-east-2_db" {
    name = "db_subnet_group_for_legacy-stellarbot-legacy-prod-us-east-2"
    subnet_ids = [
      "${aws_subnet.stellarbot-legacy-prod-us-east-2_public_a.id}",
      "${aws_subnet.stellarbot-legacy-prod-us-east-2_public_b.id}"
    ]
    tags = {
      "Name" = "DB Subnet Group for stellarbot-legacy-prod-us-east-2"
      "Reach" = "Private"
    }
}

resource "aws_route53_zone" "stellarbot-legacy-prod-us-east-2_internal_db" {
    name         = "stellarbot-legacy-prod-us-east-2.net."
    vpc {
      vpc_id     = aws_vpc.stellarbot-legacy-prod-us-east-2.id
    }
}

resource "aws_route53_record" "stellarbot-legacy-prod-us-east-2_postgres_primary" {
  zone_id     = aws_route53_zone.stellarbot-legacy-prod-us-east-2_internal_db.zone_id
  name        = "postgres-primary"
  type        = "CNAME"
  ttl         = "300"
  records     = ["${aws_db_instance.stellarbot-legacy-prod-us-east-2-postgres-primary.address}"]
}

#####
output "rds_security_group_id" {
  value = aws_security_group.stellarbot-legacy-prod-us-east-2_rds_postgres_sg.id
}

output "rds_internal_endpoint" {
  value = aws_route53_record.stellarbot-legacy-prod-us-east-2_postgres_primary.fqdn
}