output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = module.webserver.public_ip
}

output "website_url" {
  description = "URL for the exposed web page."
  value       = "http://${module.webserver.public_ip}"
}

output "vpc_id" {
  description = "ID of the VPC created by Terraform."
  value       = module.network.vpc_id
}
