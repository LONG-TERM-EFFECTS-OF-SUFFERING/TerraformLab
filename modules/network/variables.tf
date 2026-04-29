variable "name_prefix" {
  description = "Unique prefix used for network resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone where the public subnet will be created."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access HTTP port 80."
  type        = string
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
}
