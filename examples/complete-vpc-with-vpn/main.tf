locals {
  name        = "vpc"
  region      = "us-east-1"
  environment = "prod"
  additional_aws_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  vpc_cidr = "10.10.0.0/16"
}

module "key_pair_vpn" {
  source             = "squareops/keypair/aws"
  key_name           = format("%s-%s-vpn", local.environment, local.name)
  environment        = local.environment
  ssm_parameter_path = format("%s-%s-vpn", local.environment, local.name)
}

module "vpc" {
  source                                          = "squareops/vpc/aws"
  name                                            = local.name
  vpc_cidr                                        = local.vpc_cidr
  environment                                     = local.environment
  flow_log_enabled                                = false
  vpn_key_pair_name                               = module.key_pair_vpn.key_pair_name
  availability_zones                              = ["us-east-1a", "us-east-1b"]
  vpn_server_enabled                              = false
  intra_subnet_enabled                            = true
  public_subnet_enabled                           = true
  auto_assign_public_ip                           = true
  private_subnet_enabled                          = true
  one_nat_gateway_per_az                          = true
  database_subnet_enabled                         = true
  vpn_server_instance_type                        = "t3a.small"
  flow_log_max_aggregation_interval               = 60
  flow_log_cloudwatch_log_group_retention_in_days = 90
  flow_log_cloudwatch_log_group_kms_key_arn       = "arn:aws:kms:us-east-2:222222222222:key/kms_key_arn" #Enter your kms key arn
}
