output "aws-amazon-linux-ami" {
  description = "Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux
}

output "aws-security-group-id" {
  description = "Jenkins security group ID"
  value       = var.vpc_security_group_ids[0]
}

output "aws-instance-public-ip" {
  description = "Jenkins Server Instance Public IP"
  value       = aws_instance.jenkins_instance.public_ip
}

output "aws-instance-public-dns" {
  description = "Jenkins Server Instance Public DNS name"
  value       = aws_instance.jenkins_instance.public_dns
}

