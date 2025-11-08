
output "private_subnet_ids" {
  description = "List of IDs of created private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of created private subnets"
  value       = aws_subnet.private[*].cidr_block
}
