resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sg-${var.env}"
  description = "Allow traffic on ports 80, 443, 8080 and enable SSH"
  vpc_id      = var.vpc_id


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
    cidr_blocks = ["0.0.0.0/0"]
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
