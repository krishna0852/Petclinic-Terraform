resource "aws_lb" "petclinic-alb" {
  name               = var.lb-name
  internal           = false
  load_balancer_type = var.lb-type
  security_groups    = [var.sgid]
  subnets            = data.aws_subnets.getallsubnets.ids

  enable_deletion_protection = false #keep true when everthing is set
  
  
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
  depends_on = [ aws_lb_target_group.target-group ]
} 


resource "aws_lb_listener" "listen80" {
  load_balancer_arn = aws_lb.petclinic-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "tf-example-lb-tg"
  port     = 8080
  protocol = "HTTP"
  target_type ="ip"
  vpc_id   = var.vpc-id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
 
data "aws_subnets" "getallsubnets"{
  filter {
    name = "vpc-id"
    values = [var.vpc-id]
  }
  
}