resource "aws_route53_zone" "dev" {
  name = var.hosted-zone-name

  tags = {
    Environment = var.environment
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = var.app-name
  type    = var.record-type
  ttl     = "300"
  
  alias{
      name                   =var.alb-name
      zone_id                = var.alb_zoneid
      evaluate_target_health = true
  }
}

