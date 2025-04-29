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
  default     = "ami-0c55b159cbfafe1f0"
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