resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sg-${var.env}"
  description = "Allow traffic on ports 80, 443, 8080 and enable SSH"
  vpc_id      = aws_vpc.jenkins_vpc.id


  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // TODO: Restrict to external_ip only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({
    "Name" = "${var.project_name}-master-sg-${var.env}"
  }))
}


resource "aws_security_group" "jenkins_slave_sg" {
  name        = "jenkins-slave-sg-${var.env}"
  description = "Allow Jenkins master subnet access and all egress traffic"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // TODO: Restrict to jenkins master public subnet CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({
    "Name" = "${var.project_name}-slave-sg-${var.env}"
  }))
}
