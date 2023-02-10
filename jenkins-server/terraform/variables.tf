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

# variable "private_subnet_cidr_block" {
#   description = "CIDR block for private subnet"
#   type        = string
#   default     = "10.0.20.0/24"
# }

variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
  default     = "0.0.0.0/0"
}

# variable "public_key" {
#   description = "Your machine public SSH key"
#   type        = string
# }

variable "ec2_instance_type" {
  description = "Preferred EC2 instance type"
  type        = string
  default     = "t2.micro"
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

variable "tags" {
  description = "Tags to apply to all the resources"
  type        = map(string)

  default = {
    Terraform = "true"
  }
}


# GitHub Webhook variables
variable "github_repo_name" {
  description = "Name of github repository"
  type        = string
}

variable "github_owner" {
  description = "Name of github repository owner"
  type        = string
}

variable "github_repo_token" {
  description = "Github repository security token"
  type        = string
}


