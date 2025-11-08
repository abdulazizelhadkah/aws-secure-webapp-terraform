
variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where private subnets will be created"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for private subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]     # 👈 Default AZs (adjust if needed)
}

variable "tags" {
  description = "Tags to apply to all private subnets"
  type        = map(string)
  default     = {}
}
