variable "aws_region" {
  default = "eu-central-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "env" {
  description = "Environment type"
  type        = string
  default     = "dev"
}
