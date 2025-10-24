# locals {
#   az1 = data.aws_availability_zones.available.names[0]
#   az2 = data.aws_availability_zones.available.names[1]

#   tags = {
#     Project = var.project_name
#     Env     = "dev"
#   }
# }


locals {
  tags = {
    Project = var.project_name
    Env     = "dev"
  }
}

module "network" {
  source        = "./modules/network"
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  public_a_cidr = var.public_a_cidr
  public_b_cidr = var.public_b_cidr
  app_a_cidr    = var.app_a_cidr
  app_b_cidr    = var.app_b_cidr
  db_a_cidr     = var.db_a_cidr
  db_b_cidr     = var.db_b_cidr
  region        = var.region
  enable_nat    = var.enable_nat
  az_names      = data.aws_availability_zones.available.names
  common_tags   = local.tags
}

module "security" {
  source      = "./modules/security"
  vpc_id      = module.network.vpc_id
  my_ip_cidr  = var.my_ip_cidr
  common_tags = local.tags
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  common_tags  = local.tags
}

# Public ALB for web tier (port 80)
module "alb_public" {
  source         = "./modules/alb"
  name_prefix    = "${var.project_name}-alb-public"
  internal       = false
  subnets        = module.network.public_subnet_ids
  security_group = module.security.alb_public_sg_id
  vpc_id         = module.network.vpc_id
  listener_port  = 80
  target_port    = 80
  health_path    = "/"
  common_tags    = local.tags
}

# Internal ALB for app tier (port 3000)
module "alb_internal" {
  source         = "./modules/alb"
  name_prefix    = "${var.project_name}-alb-internal"
  internal       = true
  subnets        = module.network.app_subnet_ids
  security_group = module.security.alb_internal_sg_id
  vpc_id         = module.network.vpc_id
  listener_port  = 3000
  target_port    = 3000
  health_path    = "/"
  common_tags    = local.tags
}

# Web ASG (public subnets)
module "asg_web" {
  source               = "./modules/asg"
  name_prefix          = "${var.project_name}-web"
  image_id             = data.aws_ami.al2.id
  instance_type        = "t2.micro"
  subnets              = module.network.public_subnet_ids
  security_group_id    = module.security.web_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  target_group_arns    = [module.alb_public.tg_arn]
  user_data_b64        = base64encode(file("${path.module}/userdata/web.sh"))
  common_tags          = local.tags
}

# App ASG (private app subnets)
module "asg_app" {
  source               = "./modules/asg"
  name_prefix          = "${var.project_name}-app"
  image_id             = data.aws_ami.al2.id
  instance_type        = "t2.micro"
  subnets              = module.network.app_subnet_ids
  security_group_id    = module.security.app_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  target_group_arns    = [module.alb_internal.tg_arn]
  user_data_b64        = base64encode(file("${path.module}/userdata/app.sh"))
  common_tags          = local.tags
}

# RDS (DB subnets)
module "rds" {
  source                 = "./modules/rds"
  project_name           = var.project_name
  db_username            = var.db_username
  db_password            = var.db_password
  subnet_ids             = module.network.db_subnet_ids
  vpc_security_group_ids = [module.security.db_sg_id]
  common_tags            = local.tags
}