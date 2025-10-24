resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.image_id
  instance_type = var.instance_type

  iam_instance_profile { name = var.iam_instance_profile }
  vpc_security_group_ids = [var.security_group_id]
  user_data = var.user_data_b64

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, { Name = var.name_prefix })
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.subnets

  launch_template { 
    id = aws_launch_template.lt.id 
    version = "$Latest" 
  }
  target_group_arns = var.target_group_arns

  tag { 
    key = "Name" 
    value = var.name_prefix 
    propagate_at_launch = true 
  }
}