
resource "aws_lb_target_group" "this" {
  name        = "${var.gow}-${var.tg_name}"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    protocol            = var.target_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    { Name = "${var.gow}-${var.tg_name}" }
  )
}

resource "aws_lb_target_group_attachment" "attachments" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_ids[count.index]
  port             = var.target_port
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.alb_arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
