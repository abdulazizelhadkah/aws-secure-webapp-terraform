output "backend_instance_ids" {
  description = "List of backend instance IDs"
  value       = aws_instance.backend[*].id
}

output "backend_private_ips" {
  description = "List of backend private IPs"
  value       = aws_instance.backend[*].private_ip
}
