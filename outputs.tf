output "alb_public_dns" {
  value = aws_lb.public_alb.dns_name
}

output "alb_internal_dns" {
  value = aws_lb.internal_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}