# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB ingress"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.alb_ingress_cidr]
  }

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}

resource "aws_security_group" "service_sg" {
  name        = "${var.project_name}-svc-sg"
  description = "Service ENI"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = var.common_tags
}

# --- Load Balancer ---
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
  tags               = var.common_tags
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # Fargate requires target_type ip

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action { 
    type = "forward" 
    target_group_arn = aws_lb_target_group.tg.arn 
  }
}

# --- IAM for ECS Task Execution & Task Role ---
resource "aws_iam_role" "task_execution" {
  name = "${var.project_name}-task-exec"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "task_exec_ecr" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: allow reading from SSM/Secrets Manager if you use secrets
# resource "aws_iam_role_policy_attachment" "task_exec_ssm" {
#   role       = aws_iam_role.task_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = var.common_tags
}

# --- CloudWatch Logs ---
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
  tags = var.common_tags
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
  tags = var.common_tags
}

# --- Task Definition ---
locals {
  image = "${var.ecr_repo_url}:${var.image_tag}"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"                        # 0.25 vCPU
  memory                   = "512"                        # 0.5 GB
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = local.image
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = data.aws_region.current.name
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        # {"name":"NODE_ENV","value":"production"}
      ]
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = var.common_tags
}

data "aws_region" "current" {}

# --- ECS Service ---
resource "aws_ecs_service" "svc" {
  name            = "${var.project_name}-svc"
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.task.arn
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.service_sg.id]
    assign_public_ip = true # set false if in private subnets with NAT
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
  tags       = var.common_tags
}