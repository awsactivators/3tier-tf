variable "region"   { 
  type = string 
  default = "us-east-2" 
  }

variable "profile"  { 
  type = string 
  default = "default" 
}

variable "project_name" { 
  type = string 
  default = "ecs-app" 
}

variable "container_port" {
  type    = number
  default = 3000
}

# For the ALB to accept traffic (0.0.0.0/0 for demo; in prod lock to your IP)
variable "alb_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# Image tag you want to deploy (e.g., "v1", "v2")
variable "image_tag" {
  type    = string
  default = "v1"
}