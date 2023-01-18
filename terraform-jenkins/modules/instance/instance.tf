variable "vpc_id" {}
variable "public_key" {}
variable "my_ip" {}
variable "subnet_id" {}
variable "ec2_instance_type" {}

variable "project_name" {}
variable "env" {}
variable "tags" {
  type = map(string)
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  tags = merge(var.tags, tomap({
    "Name"        = "${var.project_name}-master-ec2-${var.env}",
    "Environment" = var.env
  }))

}
