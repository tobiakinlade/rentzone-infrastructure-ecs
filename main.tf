locals {
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
}

# vpc module

module "vpc" {
  source                       = "git@github.com:tobiakinlade/terraform-modules.git//vpc"
  region                       = local.region
  project_name                 = local.project_name
  environment                  = local.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

# create nat-gateways
module "nat_gateway" {
  source = "git@github.com:tobiakinlade/terraform-modules.git//nat-gateway"

  project_name               = local.project_name
  environment                = local.environment
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  internet_gateway           = module.vpc.internet_gateway
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

# create security group
module "security_group" {
  source       = "git@github.com:tobiakinlade/terraform-modules.git//security-group"
  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  ssh_ip       = var.ssh_ip
}

# launch rds instance
module "rds" {
  source                       = "git@github.com:tobiakinlade/terraform-modules.git//rds"
  project_name                 = local.project_name
  environment                  = local.environment
  private_data_subnet_az1_id   = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id   = module.vpc.private_data_subnet_az2_id
  database_snapshot_identifier = var.database_snapshot_identifier
  database_instance_class      = var.database_instance_class
  availability_zone_1          = module.vpc.availability_zone_1
  database_instance_identifier = var.database_instance_identifier
  database_security_group_id   = module.security_group.database_security_group_id
}

# request ssl certificate
module "acm" {
  source            = "git@github.com:tobiakinlade/terraform-modules.git//acm"
  domain_name       = var.domain_name
  alternative_names = var.alternative_names
}

# application load balancer
module "alb" {
  source = "git@github.com:tobiakinlade/terraform-modules.git//alb"

  project_name          = local.project_name
  environment           = local.environment
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  target_type           = var.target_type
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm.certificate_arn
}

module "s3" {
  source = "git@github.com:tobiakinlade/terraform-modules.git//s3"

  project_name         = local.project_name
  env_file_bucket_name = var.env_file_bucket_name
  env_file_name        = var.env_file_name
}

# create ecs task execution role
module "ecs_task_execution_role" {
  source               = "git@github.com:tobiakinlade/terraform-modules.git//iam-role"
  project_name         = local.project_name
  env_file_bucket_name = module.s3.env_file_bucket_name
  environment          = local.environment

}