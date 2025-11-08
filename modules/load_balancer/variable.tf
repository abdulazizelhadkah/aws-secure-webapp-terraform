variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "lb_name" {
  description = "Name suffix for the Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "internal" {
  description = "Whether the ALB is internal (true) or public (false)"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs attached to the ALB"
  type        = list(string)
}

variable "listener_port" {
  description = "Port on which the ALB listens"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the listener"
  type        = string
  default     = "HTTP"
}

variable "target_port" {
  description = "Port on target instances"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
