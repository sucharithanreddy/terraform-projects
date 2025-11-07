############################
# Common tags and helpers
############################
locals {
  common_tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Owner       = "Suchi"
  }
}

############################
# Project 1: S3 bucket
############################
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = merge(local.common_tags, {
    Name = "${var.env}-demo-bucket"
  })
}

# Enable private ACL + block public access (good practice)
resource "aws_s3_bucket_ownership_controls" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# (Optional) Versioning is useful when learning state changes
resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

############################
# Project 2: EC2 instance
############################

# Fetch your current public IP to restrict SSH (optional but safer than 0.0.0.0/0)
data "http" "my_ip" {
  # Simple IP service; if it fails or you're behind a proxy, set allow_ssh=false
  url = "https://checkip.amazonaws.com/"
}

# Strip newline from response (the service returns "x.x.x.x\n")
locals {
  my_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

# Security Group allowing SSH from your IP only (if allow_ssh=true)
resource "aws_security_group" "ssh" {
  count       = var.create_ec2 && var.allow_ssh ? 1 : 0
  name        = "${var.env}-ssh-sg"
  description = "Allow SSH from my IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.env}-ssh-sg" })
}

# Use the default VPC + a default subnet to keep things simple
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# (Optional) If you have an SSH public key at ~/.ssh/id_rsa.pub, import it.
# Comment this block if you prefer not to manage keys here.
resource "aws_key_pair" "local" {
  count      = var.create_ec2 ? 1 : 0
  key_name   = "${var.env}-key"
  public_key = file("~/.ssh/id_rsa.pub")
  tags       = local.common_tags
}

resource "aws_instance" "demo" {
  count                       = var.create_ec2 ? 1 : 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = var.allow_ssh ? [aws_security_group.ssh[0].id] : []
  associate_public_ip_address = true
  key_name                    = length(aws_key_pair.local) > 0 ? aws_key_pair.local[0].key_name : null

  tags = merge(local.common_tags, {
    Name = "${var.env}-demo-instance"
  })
}
