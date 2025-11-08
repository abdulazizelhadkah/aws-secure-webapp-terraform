output "proxy_instance_ids" {
  description = "List of proxy instance IDs"
  value       = aws_instance.proxy[*].id
}

output "proxy_public_ips" {
  description = "List of public IPs of proxy instances"
  value       = aws_instance.proxy[*].public_ip
}

output "proxy_private_ips" {
  description = "List of private IPs of proxy instances"
  value       = aws_instance.proxy[*].private_ip
}
