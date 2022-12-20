data "aws_availability_zones" "current" {
  state = "available"
}

variable "vpc_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "my_ip" {}

variable "project_name" {}
variable "env" {}


resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-${var.project_name}-VPC"
  }
}

resource "aws_subnet" "jenkins_public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = data.aws_availability_zones.current.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${var.project_name}-Public-Subnet"
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "${var.env}-${var.project_name}-Gateway"
  }
}

resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "${var.env}-${var.project_name}-Route-Table"
  }

  route {
    cidr_block = var.my_ip
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.jenkins_public_rt.id
  subnet_id      = aws_subnet.jenkins_public_subnet.id
}
