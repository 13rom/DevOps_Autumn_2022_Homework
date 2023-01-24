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


# Jenkins Master
output "aws-jenkins-master-ami" {
  description = "Amazon Linux 2 AMI"
  value       = module.jenkins_master.aws-amazon-linux-ami.description
}

output "aws-jenkins-master-security-group-id" {
  description = "Jenkins security group ID"
  value       = module.jenkins_master.aws-security-group-id
}

output "aws-jenkins-master-instance-public-ip" {
  description = "Jenkins Server Instance Public IP"
  value       = module.jenkins_master.aws-instance-public-ip
}

output "aws-jenkins-master-instance-public-dns" {
  description = "Jenkins Server Instance Public DNS name"
  value       = module.jenkins_master.aws-instance-public-dns
}


# Jenkins Slave
output "aws-jenkins-slave-ami" {
  description = "Amazon Linux 2 AMI"
  value       = module.jenkins_slave.aws-amazon-linux-ami.description
}

output "aws-jenkins-slave-security-group-id" {
  description = "Jenkins security group ID"
  value       = module.jenkins_slave.aws-security-group-id
}

output "aws-jenkins-slave-instance-public-ip" {
  description = "Jenkins Server Instance Public IP"
  value       = module.jenkins_slave.aws-instance-public-ip
}

output "aws-jenkins-slave-instance-public-dns" {
  description = "Jenkins Server Instance Public DNS name"
  value       = module.jenkins_slave.aws-instance-public-dns
}
