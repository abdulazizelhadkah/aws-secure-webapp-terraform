variable "gow" {
  description = "Prefix for resource naming"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs to place proxy instances in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for proxy servers"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of proxy instances to launch"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Name of the key pair to associate with instances"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to private key for remote provisioner"
  type        = string
}

variable "tags" {
  description = "Common tags for EC2 instances"
  type        = map(string)
  default     = {}
}

variable "internal_alb_dns_name" {
  description = "The DNS name of the internal Application Load Balancer to proxy to."
  type        = string
}