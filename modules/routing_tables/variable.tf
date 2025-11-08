variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where route tables will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID for public route table"
  type        = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for private route table"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to associate with public route table"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with private route table"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
