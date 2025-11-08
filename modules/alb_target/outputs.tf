
output "target_group_arn" {
  description = "ARN of the created Target Group"
  value       = aws_lb_target_group.this.arn
}

output "listener_arn" {
  description = "ARN of the created Listener"
  value       = aws_lb_listener.this.arn
}
