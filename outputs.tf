output "bucket_name" {
  description = "The created S3 bucket name"
  value       = aws_s3_bucket.demo.bucket
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = try(aws_instance.demo[0].id, null)
}

output "instance_public_ip" {
  description = "EC2 public IP (if instance created)"
  value       = try(aws_instance.demo[0].public_ip, null)
}

output "ssh_security_group_id" {
  description = "Security Group ID for SSH (if created)"
  value       = try(aws_security_group.ssh[0].id, null)
}