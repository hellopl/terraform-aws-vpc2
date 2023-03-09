# Declare input variables
variable "vpc_cidr" {
    description = "CIDR block for IPv4"
    type        = string
    default     = ""
}

variable "env" {
    description = "Current environment"
    type        = string
    default     = ""
}

variable "public_subnet_cidrs" {
    description = "CIDR block for IPv4 public subnet"
    type        = list
    default     = []
}

variable "private_subnet_cidrs" {
    description = "CIDR block for IPv4 private subnet"
    type        = list
    default     = []
}