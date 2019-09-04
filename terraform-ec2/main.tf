terraform {
  required_version = "= 0.12.7"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ami" "amazon-linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["docker-amazon-linux2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon-linux2.image_id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  key_name = aws_key_pair.master-key.key_name

  vpc_security_group_ids = [aws_security_group.web.id]
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "web-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}