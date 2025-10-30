locals {
  tags = {
    Project = var.project_name
    Env     = "dev"
  }
}

# 1) ECR repository for your app
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  common_tags  = local.tags
}

# 2) ECS (cluster, task def, service, ALB, SGs, logs)
module "ecs_fargate" {
  source          = "./modules/ecs_fargate"
  project_name    = var.project_name
  vpc_id          = data.aws_vpc.default.id
  subnet_ids      = data.aws_subnets.default.ids
  ecr_repo_url    = module.ecr.repository_url
  image_tag       = var.image_tag
  container_port  = var.container_port
  alb_ingress_cidr = var.alb_ingress_cidr
  common_tags     = local.tags
}