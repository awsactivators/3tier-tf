# ALB (public) — allow HTTP from your IP
resource "aws_security_group" "alb_public_sg" {
  name        = "${var.project_name}-alb-public-sg"
  description = "Public ALB SG"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Web EC2 — allow HTTP from public ALB only
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  vpc_id      = aws_vpc.this.id
  description = "Web tier EC2 SG"

  ingress {
    description     = "HTTP from public ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# Internal ALB — allow from Web EC2
resource "aws_security_group" "alb_internal_sg" {
  name        = "${var.project_name}-alb-internal-sg"
  vpc_id      = aws_vpc.this.id
  description = "Internal ALB SG"

  ingress {
    description     = "App port 3000 from Web SG"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# App EC2 — allow 3000 from Internal ALB only
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  vpc_id      = aws_vpc.this.id
  description = "App tier EC2 SG"

  ingress {
    description     = "Port 3000 from internal ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# DB — allow 3306 from App SG
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  vpc_id      = aws_vpc.this.id
  description = "DB SG"

  ingress {
    description     = "MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}