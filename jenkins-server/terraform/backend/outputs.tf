# Terraform AWS S3 Backend
output "terraform-state-bucket-name" {
  description = "Name of the remote state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

