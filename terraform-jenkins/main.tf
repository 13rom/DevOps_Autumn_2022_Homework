provider "aws" {
  region  = var.aws_region
  profile = "jenkins"
}


data "aws_availability_zones" "current" {}
data "aws_region" "current" {}


module "network" {
  source                   = "./modules/vpc"
  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  my_ip                    = var.my_ip
}

module "jenkins_server" {
  source            = "./modules/jenkins-server"
  my_ip             = var.my_ip
  public_key        = var.public_key
  vpc_id            = module.network.vpc-id
  subnet_id         = module.network.public-subnet-id
  ec2_instance_type = var.ec2_instance_type
}

