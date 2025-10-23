data "aws_availability_zones" "available" {
  state = "available"
}

# Amazon Linux 2 (AL2) x86_64 latest
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}