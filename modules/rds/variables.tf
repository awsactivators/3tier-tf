variable "project_name"         { 
  type = string 
}

variable "db_username"          { 
  type = string 
}

variable "db_password"          { 
  type = string
  sensitive = true 
}

variable "subnet_ids"           { 
  type = list(string) 
}

variable "vpc_security_group_ids" { 
  type = list(string) 
}

variable "common_tags"          { 
  type = map(string) 
}