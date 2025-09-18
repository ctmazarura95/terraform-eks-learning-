variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "security_groups" {
  description = "Map of security groups with their rules"
  type = map(object({
    name = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}