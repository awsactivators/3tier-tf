variable "region" {
  type    = string
  default = "us-east-2"
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
  description = "Your IP in CIDR, e.g. 1.2.3.4/32"
}

variable "enable_nat" {
  type        = bool
  default     = false
  description = "Enable NAT GW for private app egress (NOT free-tier)."
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

# VPC/subnet CIDRs (edit if you like)
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_a_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_b_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "app_a_cidr" {
  type    = string
  default = "10.0.11.0/24"
}

variable "app_b_cidr" {
  type    = string
  default = "10.0.12.0/24"
}

variable "db_a_cidr" {
  type    = string
  default = "10.0.21.0/24"
}

variable "db_b_cidr" {
  type    = string
  default = "10.0.22.0/24"
}