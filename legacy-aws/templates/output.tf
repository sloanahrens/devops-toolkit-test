# outputs

output "legacy_web_server_public_dns" {
  value = aws_route53_record.legacy-web-public-REGION-DEPLOYMENT_TYPE.fqdn
}

output "color_legacy_web_server_ip" {
  value = aws_instance.legacy_web_server-DEPLOYMENT_TYPE-REGION-COLOR.public_ip
}

output "color_legacy_web_server_public_dns" {
  value = aws_route53_record.legacy-web-public-REGION-DEPLOYMENT_TYPE-COLOR.fqdn
}