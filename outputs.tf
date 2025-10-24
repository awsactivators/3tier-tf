output "alb_public_dns" {
  value = module.alb_public.lb_dns
}

output "alb_internal_dns" {
  value = module.alb_internal.lb_dns
}

output "rds_endpoint" {
  value = module.rds.endpoint
}