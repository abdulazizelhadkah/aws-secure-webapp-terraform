
variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where the NAT Gateway will be created"
  type        = string

}

variable "dependency_igw" {
  description = "Internet Gateway dependency to ensure proper creation order"
  type        = any
}

variable "tags" {
  description = "Tags to apply to NAT Gateway and EIP"
  type        = map(string)
  default     = {}
}
