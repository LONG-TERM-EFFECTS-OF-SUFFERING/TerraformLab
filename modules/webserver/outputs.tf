output "public_ip" {
  description = "Public IP address of the EC2 web server."
  value       = aws_instance.web.public_ip
}
