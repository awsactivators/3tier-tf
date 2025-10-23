variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "project_name" {
  type    = string
  default = "three-tier"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your IP in CIDR form, e.g. 1.2.3.4/32"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type        = string
  description = "RDS password"
  sensitive   = true
}

variable "enable_nat" {
  type        = bool
  default     = false
  description = "Enables a NAT Gateway so private instances can reach the internet (NOT free tier)."
}