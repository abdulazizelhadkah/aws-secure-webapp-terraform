variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to attach the Internet Gateway to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Internet Gateway"
  type        = map(string)
  default     = {}
}
