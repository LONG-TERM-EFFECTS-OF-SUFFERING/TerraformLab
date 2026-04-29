variable "name_prefix" {
  description = "Unique prefix used to name and tag all resources for this deployment. Change this value in a new Terraform Cloud workspace to create a second copy without overwriting the first."
  type        = string
  default     = "brandon-iac"
}

variable "person_name" {
  description = "Name shown on the web page."
  type        = string
  default     = "Brandon"
}

variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the web server."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access the web server over HTTP. Use 0.0.0.0/0 for public access."
  type        = string
  default     = "0.0.0.0/0"
}

variable "common_tags" {
  description = "Common tags applied to all supported resources."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
