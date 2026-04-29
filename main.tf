locals {
  tags = merge(var.common_tags, {
    Project  = var.name_prefix
    Owner    = var.person_name
    Workshop = "IaC"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "./modules/network"

  name_prefix        = var.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = data.aws_availability_zones.available.names[0]
  allowed_http_cidr  = var.allowed_http_cidr
  tags               = local.tags
}

module "webserver" {
  source = "./modules/webserver"

  name_prefix       = var.name_prefix
  person_name       = var.person_name
  ami_id            = data.aws_ami.amazon_linux_2023.id
  instance_type     = var.instance_type
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.web_security_group_id
  tags              = local.tags
}
