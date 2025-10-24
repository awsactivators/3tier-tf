# Public ALB SG (HTTP from your IP)
resource "aws_security_group" "alb_public" {
  name        = "alb-public-sg"
  vpc_id      = var.vpc_id
  description = "Public ALB"

  ingress { 
    from_port = 80 
    to_port = 80 
    protocol = "tcp" 
    cidr_blocks = [var.my_ip_cidr] 
  }
  egress  { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = var.common_tags
}

# Web EC2 SG (HTTP from public ALB)
resource "aws_security_group" "web" {
  name        = "web-sg"
  vpc_id      = var.vpc_id
  description = "Web tier"

  ingress {
    description     = "HTTP from public ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public.id]
  }
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}

# Internal ALB SG (3000 from Web SG)
resource "aws_security_group" "alb_internal" {
  name        = "alb-internal-sg"
  vpc_id      = var.vpc_id
  description = "Internal ALB"

  ingress {
    description     = "3000 from web SG"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}

# App EC2 SG (3000 from internal ALB)
resource "aws_security_group" "app" {
  name        = "app-sg"
  vpc_id      = var.vpc_id
  description = "App tier"

  ingress {
    description     = "3000 from internal ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal.id]
  }
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}

# DB SG (3306 from app SG)
resource "aws_security_group" "db" {
  name        = "db-sg"
  vpc_id      = var.vpc_id
  description = "DB tier"

  ingress {
    description     = "3306 from app SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}