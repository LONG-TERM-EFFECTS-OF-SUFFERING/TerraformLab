resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -euxo pipefail

dnf install -y httpd
systemctl enable --now httpd

cat > /var/www/html/index.html <<HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>IaC Workshop</title>
  </head>
  <body>
    <h1>Hi, I am ${var.person_name} and this is my IaC</h1>
  </body>
</html>
HTML
EOF

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-webserver"
  })
}
