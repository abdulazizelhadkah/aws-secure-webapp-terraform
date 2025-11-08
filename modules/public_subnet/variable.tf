variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where public subnets will be created"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]  
  }

variable "availability_zones" {
  description = "List of availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Tags to apply to all public subnets"
  type        = map(string)
  default     = {}
}
