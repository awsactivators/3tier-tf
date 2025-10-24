variable "name_prefix"          { 
  type = string 
  }

variable "image_id"             { 
  type = string 
  }

variable "instance_type"        { 
  type = string 
  }

variable "subnets"              { 
  type = list(string) 
  }

variable "security_group_id"    { 
  type = string 
  }

variable "iam_instance_profile" { 
  type = string 
  }

variable "target_group_arns"    { 
  type = list(string) 
  }

variable "user_data_b64"        { 
  type = string 
  }

variable "common_tags"          { 
  type = map(string) 
  }