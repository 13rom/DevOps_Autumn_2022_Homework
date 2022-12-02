# AWS VPC
output "aws-current-region" {
  description = "Name of the current AWS region"
  value       = data.aws_region.current.name
}

output "aws-current-availability-zone" {
  description = "Name of the availability zone"
  value       = data.aws_availability_zones.current.names[0]
}

output "aws-jenkins-vpc-id" {
  description = "ID of Jenkins VPC network"
  value       = module.network.vpc-id
}

output "aws-jenkins-public-subnet-id" {
  description = "ID of Jenkins public subnet"
  value       = module.network.public-subnet-id
}


# Jenkins Server
output "aws-amazon-linux-ami" {
  description = "Amazon Linux 2 AMI"
  value       = module.jenkins_server.aws-amazon-linux-ami.description
}

output "aws-jenkins-security-group-id" {
  description = "Jenkins security group ID"
  value       = module.jenkins_server.aws-jenkins-security-group-id
}

output "aws-jenkins-instance-public-ip" {
  description = "Jenkins Server Instance Public IP"
  value       = module.jenkins_server.aws-jenkins-instance-public-ip
}

output "aws-jenkins-instance-public-dns" {
  description = "Jenkins Server Instance Public DNS name"
  value       = module.jenkins_server.aws-jenkins-instance-public-dns
}
