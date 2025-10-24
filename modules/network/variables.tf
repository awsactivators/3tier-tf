variable "project_name" { 
  type = string 
  default = "three-tier" 
}

variable "vpc_cidr"     { 
  type = string
  default = "10.0.0.0/16"
}

variable "public_a_cidr"{ 
  type = string
  default = "10.0.1.0/24"
}

variable "public_b_cidr"{ 
  type = string
  default = "10.0.2.0/24"
}

variable "app_a_cidr"   { 
  type = string
  default = "10.0.11.0/24"
}

variable "app_b_cidr"   { 
  type = string
  default = "10.0.12.0/24"
}

variable "db_a_cidr"    { 
  type = string
  default = "10.0.21.0/24"
}

variable "db_b_cidr"    { 
  type = string
  default = "10.0.22.0/24"
}

variable "region"     { 
  type = string
  default = "us-east-1"
}

variable "enable_nat" { 
  type = bool
  default = true
}

variable "az_names"   { 
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "common_tags"{ 
  type = map(string)
  default = {
    Project = "three-tier"
    Env     = "dev"
  }
}