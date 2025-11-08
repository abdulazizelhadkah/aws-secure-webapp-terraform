
output "igw_id" {
  description = "The ID of the created Internet Gateway"
  value       = aws_internet_gateway.this.id
}
