# environment variable
variable "region" {}
variable "project_name" {}
variable "environment" {}

# vpc variables
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}


# security group variable
variable "ssh_ip" {}

# rds variables
variable "database_snapshot_identifier" {}
variable "database_instance_class" {}
variable "database_instance_identifier" {}

# acm variables

variable "domain_name" {}
variable "alternative_names" {}

# alb variable
variable "target_type" {}

# s3 variables
variable "env_file_bucket_name" {}
variable "env_file_name" {}




