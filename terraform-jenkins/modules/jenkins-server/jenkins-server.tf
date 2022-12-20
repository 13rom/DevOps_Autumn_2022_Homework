variable "vpc_id" {}
variable "public_key" {}
variable "my_ip" {}
variable "subnet_id" {}
variable "ec2_instance_type" {}

variable "project_name" {}
variable "env" {}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins_security_group"
  description = "Allow traffic on ports 80, 443, 8080 and enable SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.project_name}-Security-Group"
  }
}

resource "aws_key_pair" "jenkins_ssh_key" {
  key_name   = "jenkins-ssh-key"
  public_key = var.public_key
}

resource "aws_instance" "jenkins_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  key_name               = aws_key_pair.jenkins_ssh_key.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]

  tags = {
    Name = "${var.env}-${var.project_name}-Server-Instance"
  }

}
