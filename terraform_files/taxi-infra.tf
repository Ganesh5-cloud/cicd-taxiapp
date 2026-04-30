provider "aws" {
  region = "us-east-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# ONLY pick public subnets (critical fix)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Security Group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow SSH + Web"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IMPORTANT: allow outbound internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}

# =========================
# EC2 INSTANCES
# =========================

# Common settings applied to all:
# - public subnet
# - public IP
# - same SG

resource "aws_instance" "ansible" {
  ami                         = "ami-04680790a315cd58d"
  instance_type               = "t2.micro"
  key_name                    = "taxi"
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.demo-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ansible"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = "ami-04680790a315cd58d"
  instance_type               = "t2.micro"
  key_name                    = "taxi"
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.demo-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "jenkins_master"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                         = "ami-04680790a315cd58d"
  instance_type               = "t2.micro"
  key_name                    = "taxi"
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.demo-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "jenkins_slave"
  }
}
