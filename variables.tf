variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment name used in tags and names"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Unique S3 bucket name (must be globally unique)"
  type        = string
  # Example in tfvars: "vyshu-tf-demo-123456"
}

variable "create_ec2" {
  description = "Whether to create an EC2 instance for practice"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # free-tier eligible: t2.micro/t3.micro (check your region)
}

variable "allow_ssh" {
  description = "Allow SSH (22) to the instance from your public IP"
  type        = bool
  default     = true
}
