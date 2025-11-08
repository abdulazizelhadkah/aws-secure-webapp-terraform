
variable "gow" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name for the security group (suffix)"
  type        = string
}

variable "sg_description" {
  description = "Description for the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = <<EOT
List of ingress rules. Each rule is an object with:
{
  from_port = number,
  to_port   = number,
  protocol  = string,
  cidr_blocks = optional(list(string)),
  source_security_group_id = optional(string),
  description = optional(string)
}
EOT
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
    description              = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = <<EOT
List of egress rules. Each rule is an object with:
{
  from_port = number,
  to_port   = number,
  protocol  = string,
  cidr_blocks = optional(list(string)),
  description = optional(string)
}
EOT
  type = list(object({
    from_port    = number
    to_port      = number
    protocol     = string
    cidr_blocks  = optional(list(string))
    description  = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Common tags for the security group"
  type        = map(string)
  default     = {}
}
