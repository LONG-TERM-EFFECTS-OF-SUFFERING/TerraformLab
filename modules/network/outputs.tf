output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the created public subnet."
  value       = aws_subnet.public.id
}

output "web_security_group_id" {
  description = "ID of the security group used by the web server."
  value       = aws_security_group.web.id
}
