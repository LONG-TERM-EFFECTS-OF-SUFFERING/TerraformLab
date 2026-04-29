variable "name_prefix" {
  description = "Unique prefix used for the EC2 instance name."
  type        = string
}

variable "person_name" {
  description = "Name shown in the HTML page."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used by the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to the EC2 instance."
  type        = string
}

variable "tags" {
  description = "Tags applied to the EC2 instance."
  type        = map(string)
}
