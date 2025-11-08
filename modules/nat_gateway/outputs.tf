
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "nat_eip_id" {
  description = "The ID of the Elastic IP for the NAT Gateway"
  value       = aws_eip.nat.id
}

output "nat_eip_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
