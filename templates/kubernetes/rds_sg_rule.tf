resource "aws_security_group_rule" "DEPLOYMENT_NAME_all_nodes_to_postgres" {
  from_port                = POSTGRES_PORT
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes-DEPLOYMENT_NAME-k8s-local.id
  source_security_group_id = "RDS_SG_ID"
  to_port                  = POSTGRES_PORT
  type                     = "ingress"
}