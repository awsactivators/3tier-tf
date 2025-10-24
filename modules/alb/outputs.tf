output "lb_arn" { 
  value = aws_lb.this.arn 
  }

output "lb_dns" { 
  value = aws_lb.this.dns_name 
  }

output "tg_arn" { 
  value = aws_lb_target_group.tg.arn 
  }