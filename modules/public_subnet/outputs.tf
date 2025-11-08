
output "public_subnet_ids" {
  description = "List of IDs of created public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of created public subnets"
  value       = aws_subnet.public[*].cidr_block
}
