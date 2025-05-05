provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
  vpc_name   = var.vpc_name
  env        = var.env

  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
  azs                = var.azs
  service_ports      = var.service_ports
}

module "iam" {
  source = "./modules/iam"
  name   = module.vpc.vpc_name
  env    = module.vpc.Environment
}

module "ec2" {
  source = "./modules/ec2"

  ami                  = var.ami
  instance_type        = var.instance_type
  public_subnet_id     = module.vpc.public-subnet
  iam_instance_profile = module.iam.iam_role_name
  vpc_name             = module.vpc.vpc_name
  sg-id                = module.vpc.sg
  env                  = module.vpc.Environment
  key_name             = var.key
}

module "db" {
  source            = "./modules/rds"
  name              = module.vpc.vpc_name
  subnet_ids        = module.vpc.public_subnet_id
  env               = module.vpc.Environment
  db_name           = var.db_name
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  username          = var.username
  password          = var.password
}
