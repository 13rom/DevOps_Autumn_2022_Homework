output "aws-amazon-linux-ami" {
  description = "Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux
}

output "aws-jenkins-security-group-id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins_master_sg.id
}

output "aws-jenkins-instance-public-ip" {
  description = "Jenkins Server Instance Public IP"
  value       = aws_instance.jenkins_instance.public_ip
}

output "aws-jenkins-instance-public-dns" {
  description = "Jenkins Server Instance Public DNS name"
  value       = aws_instance.jenkins_instance.public_dns
}

