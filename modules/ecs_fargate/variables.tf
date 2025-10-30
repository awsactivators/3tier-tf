variable "project_name" { 
  type = string 
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" { 
  type = list(string) 
}

variable "ecr_repo_url" {
  type = string
}

variable "image_tag" { 
  type = string 
}

variable "container_port" {
  type = number
}

variable "alb_ingress_cidr" { 
  type = string 
}

variable "common_tags" { 
  type = map(string) 
}