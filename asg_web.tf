data "template_cloudinit_config" "web_userdata" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
#!/bin/bash
set -euxo pipefail

# Become ec2-user shell for NVM env setup
su - ec2-user -c '
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install 16
  nvm use 16
  mkdir -p ~/web-tier
  aws s3 cp s3://mytumisbucket/web-tier/ ~/web-tier --recursive
  cd ~/web-tier
  npm install
  npm run build
'

amazon-linux-extras install nginx1 -y
cd /etc/nginx
rm -f nginx.conf
aws s3 cp s3://mytumisbucket/nginx.conf .
service nginx restart
chmod -R 755 /home/ec2-user
chkconfig nginx on
EOF
  }
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.al2.id
  instance_type = "t2.micro"

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = data.template_cloudinit_config.web_userdata.rendered

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.project_name}-web" })
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-asg-web"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }
}