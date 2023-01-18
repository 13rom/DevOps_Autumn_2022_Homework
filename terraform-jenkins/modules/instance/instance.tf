variable "key_name" {}
variable "subnet_id" {}
variable "vpc_security_group_ids" {}
variable "ec2_instance_type" {}

variable "name" {}
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

resource "aws_instance" "jenkins_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = merge(var.tags, tomap({
    "Name"        = "${var.project_name}-${var.name}-ec2-${var.env}",
    "Environment" = var.env
  }))

}
