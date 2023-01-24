output "public-subnet-id" {
  description = "ID of the public subnet"
  value       = aws_subnet.jenkins_public_subnet.id
}

output "vpc-id" {
  description = "ID of Jenkins VPC"
  value       = aws_vpc.jenkins_vpc.id
}

output "master-sg-id" {
  description = "ID of master security group"
  value       = aws_security_group.jenkins_master_sg.id
}

output "slave-sg-id" {
  description = "ID of slave security group"
  value       = aws_security_group.jenkins_slave_sg.id
}
