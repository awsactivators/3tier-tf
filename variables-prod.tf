
variable "project_name_prod" {
  type        = string
  default     = "three-tier-prod"
  description = "Project name for production resources."
  
}

variable "db_username_prod" {
  type    = string
  default = "appuser"
}
