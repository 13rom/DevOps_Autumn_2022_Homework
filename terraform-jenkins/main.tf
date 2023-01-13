# Terraform Jenkins server deployment
#
#
# Tutorial:
# https://www.freecodecamp.org/news/learn-terraform-by-deploying-jenkins-server-on-aws/
# https://github.com/Caesarsage/terraform-jenkins-instance/blob/main/development/main.tf
#
#
#
# TODO: Make AMI selection to depend on var.env
# TODO: Make VPC module to create given number of subnets
# TODO: Make jenkins-server module to deploy given number of agent nodes
# TODO: Implement a DynamoDB table lock to prevent simultaneous writing - https://technology.doximity.com/articles/terraform-s3-backend-best-practices
# TODO: Automate Jenkins master initial jobs deployment
# TODO: Run ansible from terraform
# TODO: Add iam_instance_profile to jenkins master instance

provider "aws" {
  region  = var.aws_region
  profile = "jenkins"
}

# TODO: Automate this block
terraform {
  backend "s3" {
    bucket  = "terraform-state-mirom-jenkins-dev"
    key     = "terraform-jenkins/terraform.tfstate"
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

module "jenkins_server" {
  source            = "./modules/jenkins-server"
  ec2_instance_type = var.ec2_instance_type
  vpc_id            = module.network.vpc-id
  subnet_id         = module.network.public-subnet-id
  my_ip             = var.my_ip
  public_key        = var.public_key

  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}

