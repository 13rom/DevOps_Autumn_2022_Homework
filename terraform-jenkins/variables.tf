variable "aws_region" {
  default = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.20.0/24"
}

variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
  default     = "0.0.0.0/0"
}

variable "public_key" {
  description = "Your machine public SSH key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQTuJarvjujsBB9egxsw94XeG5Z+7DdY9Yu/+lBNaNfE6Qdwsu/GuBie8Ndhf3u2nVk5A3VUmLRFwAZR4r9/Vwyc8RnYOwtA/Q1RuAJPXjgDj+M3DqQR1b3288ThKcGqR197GaYjy9uEw/Sc5OP3S6SU/JymR+X9RbEFYNedo17qo09GGKZmrkD8LqVYGkQKlY0IGZLf7IUcDaSVfi7T8zk/Ji4+5auTe3g0QH0swaO7Vyx6DjW74XXQv7S+xsiamhpoBuqx9AUqRPg5sIu9P7ElwNGgLGVGjhq0ypgStJcTL9jd8bW0nSP0PG2tTq7BhbXFGCKt5CrQEgvATbAeY6NsUchpwTkuBceLbpKECbUxri/WKH4RyMRsqlTLQ1B0svCha8k2RhuB+qYHMxsTnz+vA7DeXrX+VDFkYyYWZ2dUDzVQIlNH4tZKX8xwP5yB0eB/ZJ1b4ybiQ4+vyg2aMAnDNBz5VlhpoUcYCEl5jpvwh776QWFTXKBy/uP3Ynh3s= oleg@latitude-laptop"
}

variable "ec2_instance_type" {
  description = "Preferred EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "Jenkins"
}

variable "env" {
  description = "Environment type"
  type        = string
  default     = "dev"
}
