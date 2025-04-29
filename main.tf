# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (update based on region)
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "deployer-key"
}

variable "my_public_key" {
  description = "Your public SSH key"
  type        = string
}

variable "your_public_key" {
  description = "My public SSH key"
  type        = string
}

# Key pair for SSH access
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.my_public_key
}

# Security group (Cloud Firewall)
resource "aws_security_group" "server_sg" {
  name        = "server-security-group"
  description = "Security group for servers"

  # Inbound rules
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL from servers only"
    from_port   = 5432
    to_port     = 5435
    protocol    = "tcp"
    self        = true # Allow traffic only from instances in this security group
  }

  # Outbound rules (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instances
resource "aws_instance" "server" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.server_sg.name]

  tags = {
    Name = "Server-${count.index + 1}"
  }

  # Add additional SSH key (your key) to authorized_keys
  user_data = <<-EOF
              #!/bin/bash
              echo "${var.your_public_key}" >> /home/ec2-user/.ssh/authorized_keys
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
              EOF
}

# Outputs
output "instance_ips" {
  description = "Public IPs of the created instances"
  value       = aws_instance.server[*].public_ip
}