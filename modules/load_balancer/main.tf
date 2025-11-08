resource "aws_lb" "this" {
  name               = "${var.gow}-${var.lb_name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-${var.lb_name}"
    }
  )
}

resource "aws_lb_target_group" "this" {
  name        = "${var.gow}-${var.lb_name}-tg"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-${var.lb_name}-tg"
    }
  )
}

#resource "aws_lb_listener" "this" {
#  load_balancer_arn = aws_lb.this.arn
#  port              = var.listener_port
#  protocol          = var.listener_protocol

# default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.this.arn
#  }
#}
