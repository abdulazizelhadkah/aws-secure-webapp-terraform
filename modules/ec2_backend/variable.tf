variable "gow" {
  description = "Prefix for resource naming"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs to place backend instances in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for backend instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for backend servers"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of backend instances to launch"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Name of the key pair to associate with instances"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to private key for SSH connection"
  type        = string
}

variable "local_backend_path" {
  description = "Path to local backend app folder (contains app.py, etc.)"
  type        = string
}

variable "tags" {
  description = "Common tags for backend instances"
  type        = map(string)
  default     = {}
}

variable "proxy_public_ip" {
  description = "Public IP address of the proxy instance"
  type        = string
}