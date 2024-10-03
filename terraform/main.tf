provider "aws" {
  profile = "qiross"
  region  = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "env_name" {
  description = "Name of the environment (e.g., dev, staging, prod)"
  type        = string
}

# Security group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "${var.env_name}-allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count         = var.instance_count
  key_name      = "qiross"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "${var.env_name}-app-instance"
  }
}

output "instance_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.app[*].public_ip
}

output "instance_ids" {
  description = "Instance IDs of EC2 instances"
  value       = aws_instance.app[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = aws_instance.app[*].private_ip
}
