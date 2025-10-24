resource "aws_lb" "this" {
  name               = var.name_prefix
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.security_group]
  tags               = var.common_tags
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.name_prefix}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = var.health_path
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
  }
  tags = var.common_tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"
  default_action { 
    type = "forward" 
    target_group_arn = aws_lb_target_group.tg.arn 
  }
}