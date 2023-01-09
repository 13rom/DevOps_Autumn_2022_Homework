provider "aws" {
  region  = var.aws_region
  profile = "jenkins"
}

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
}

