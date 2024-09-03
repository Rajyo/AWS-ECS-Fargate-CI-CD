variable "vpc_id" {}
variable "private_subnet_id" {}
variable "security_group_id" {}


output "lb_tg_arn" {
  value = aws_lb_target_group.web_server_target_group.arn
}


resource "aws_lb_target_group" "web_server_target_group" {
  name        = "aws-cql-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_lb" "web_server_load_balancer" {
  name               = "aws-cql-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.private_subnet_id
  security_groups    = [var.security_group_id]

  tags = {
    Name = "Web server load balancer"
  }
}

resource "aws_lb_listener" "web_server_alb_listener" {
  load_balancer_arn = aws_lb.web_server_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_target_group.arn
  }
}
