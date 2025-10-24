variable "name_prefix"    { 
  type = string 
  }

variable "internal"       { 
  type = bool 
  default = false 
  }

variable "subnets"        { 
  type = list(string) 
  }

variable "security_group" { 
  type = string 
  }

variable "vpc_id"         { 
  type = string 
  }

variable "listener_port"  { 
  type = number 
  }

variable "target_port"    { 
  type = number 
  }

variable "health_path"    { 
  type = string 
  default = "/" 
  }

variable "common_tags"    { 
  type = map(string) 
  }