data "template_cloudinit_config" "app_userdata" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    yum -y update || true
    yum -y install mariadb105 || yum -y install mariadb || true

    su - ec2-user -c '
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
      . ~/.nvm/nvm.sh
      nvm install 16
      nvm use 16
      npm install -g pm2
      mkdir -p ~/app-tier
      aws s3 cp s3://mytumisbucket/app-tier/ ~/app-tier --recursive
      cd ~/app-tier
      npm install
      pm2 start index.js
      pm2 list
      pm2 logs --lines 10
      pm2 startup | sed "s/sudo //g" | bash
    '
    EOF
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ami.al2.id
  instance_type = "t2.micro"

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = data.template_cloudinit_config.app_userdata.rendered

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.project_name}-app" })
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.project_name}-asg-app"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }
}