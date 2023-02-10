# Terraform Jenkins server deployment
#
# TODO: Make AMI selection to depend on var.env
# TODO: Make VPC module to create given number of subnets
# TODO: Make jenkins-server module to deploy given number of agent nodes
# TODO: Implement a DynamoDB table lock to prevent simultaneous writing - https://technology.doximity.com/articles/terraform-s3-backend-best-practices
# TODO: Run ansible from terraform
# TODO: Add iam_instance_profile to jenkins master instance

provider "aws" {
  region  = var.aws_region
  profile = "jenkins"
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-mirom-jenkins-dev"
    key     = "jenkins-server/terraform/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    profile = "jenkins"
  }
}

data "aws_availability_zones" "current" {}
data "aws_region" "current" {}


module "network" {
  source                   = "./modules/vpc"
  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  my_ip                    = var.my_ip

  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}

resource "aws_key_pair" "jenkins_ssh_key" {
  key_name   = "jenkins-ssh-key"
  public_key = file("../.ssh/jenkins_rsa.pub")
}

module "jenkins_master" {
  source                 = "./modules/instance"
  ec2_instance_type      = var.ec2_instance_type
  subnet_id              = module.network.public-subnet-id
  private_ip             = "10.0.10.5"
  vpc_security_group_ids = [module.network.master-sg-id]
  key_name               = aws_key_pair.jenkins_ssh_key.key_name

  name         = "master"
  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}

module "jenkins_slave" {
  source                 = "./modules/instance"
  ec2_instance_type      = var.ec2_instance_type
  subnet_id              = module.network.public-subnet-id
  private_ip             = "10.0.10.15"
  vpc_security_group_ids = [module.network.slave-sg-id]
  key_name               = aws_key_pair.jenkins_ssh_key.key_name

  name         = "slave"
  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}

module "github_webhook" {
  source = "./modules/webhook"

  github_owner       = var.github_owner      # 13rom
  github_repo_token  = var.github_repo_token # ghp_dhc47...
  github_repo_name   = var.github_repo_name  # sample-webapp
  github_webhook_url = "http://${module.jenkins_master.aws-instance-public-dns}:8080/github-webhook/"
}
