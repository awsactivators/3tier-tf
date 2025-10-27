module "rds-prod" {
  source                 = "./modules/rds"
  project_name           = var.project_name_prod
  db_username            = var.db_username_prod
  db_password            = var.db_password
  subnet_ids             = module.network.db_subnet_ids
  vpc_security_group_ids = [module.security.db_sg_id]
  common_tags            = local.tags
}