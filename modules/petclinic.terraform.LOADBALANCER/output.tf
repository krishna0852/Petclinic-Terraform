output "tgroup_arn" {
  value = aws_lb_target_group.target-group.arn
}

output "alb-dns"{
  value=aws_lb.petclinic-alb.dns_name
}
output "zoneid"{
  value=aws_lb.petclinic-alb.zone_id
}

