resource "aws_lb" "internal_alb" {
  name               = "${var.project_name}-alb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal_sg.id]
  subnets            = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  tags               = local.tags
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg-app"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  health_check {
    path    = "/"
    port    = "3000"
    matcher = "200-399"
  }
  tags = local.tags
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}