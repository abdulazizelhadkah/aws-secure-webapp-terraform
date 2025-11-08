variable "gow" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Target Group"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the load balancer to attach listener to"
  type        = string
}

variable "tg_name" {
  description = "Name for the target group"
  type        = string
}

variable "target_port" {
  description = "Port on EC2 instances to forward traffic to"
  type        = number
}

variable "target_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Port the ALB listens on"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol the ALB listener uses"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Path used for health checks"
  type        = string
  default     = "/"
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to register in the Target Group"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to Target Group"
  type        = map(string)
  default     = {}
}
