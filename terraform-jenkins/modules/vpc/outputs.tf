output "public-subnet-id" {
  description = "ID of the public subnet"
  value       = aws_subnet.jenkins_public_subnet.id
}

output "vpc-id" {
  description = "ID of Jenkins VPC"
  value       = aws_vpc.jenkins_vpc.id
}
