output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "alb_dns_name" {
  value = module.ecs_fargate.alb_dns_name
}

output "service_name" {
  value = module.ecs_fargate.service_name
}