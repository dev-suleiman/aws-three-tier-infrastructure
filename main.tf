module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
}

module "s3" {
  source      = "./modules/s3"
  environment = var.environment
  bucket_name = var.bucket_name
}


module "secrets" {
  source      = "./modules/secrets"
  environment = var.environment
  db_username = var.db_username
  db_password = var.db_password
}

module "iam" {
  source        = "./modules/iam"
  environment   = var.environment
  s3_bucket_arn = module.s3.bucket_arn
  db_secret_arn = module.secrets.db_secret_arn
}

module "web_alb" {
  source      = "./modules/alb"
  environment = var.environment
  name        = "web"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids
  internal    = false
  ingress_cidr = "0.0.0.0/0"
  target_port  = 80
}

module "web_asg" {
  source                    = "./modules/asg"
  environment               = var.environment
  name                      = "web"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  alb_security_group_id     = module.web_alb.security_group_id
  target_group_arn          = module.web_alb.target_group_arn
  iam_instance_profile_name = module.iam.web_tier_instance_profile_name
  instance_type             = var.instance_type
  public_key_path           = var.public_key_path
  min_size                  = var.web_min_size
  max_size                  = var.web_max_size
  desired_capacity          = var.web_desired_capacity

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx
  EOF
}

module "app_alb" {
  source                    = "./modules/alb"
  environment               = var.environment
  name                      = "app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  internal                  = true
  ingress_security_group_id = module.web_asg.security_group_id
  target_port               = 80
}

module "app_asg" {
  source                    = "./modules/asg"
  environment               = var.environment
  name                      = "app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  alb_security_group_id     = module.app_alb.security_group_id
  target_group_arn          = module.app_alb.target_group_arn
  iam_instance_profile_name = module.iam.app_tier_instance_profile_name
  instance_type             = var.instance_type
  public_key_path           = var.public_key_path
  min_size                  = var.app_min_size
  max_size                  = var.app_max_size
  desired_capacity          = var.app_desired_capacity

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
  EOF
}

module "rds" {
  source                    = "./modules/rds"
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  database_subnet_ids       = module.vpc.database_subnet_ids
  allowed_security_group_id = module.app_asg.security_group_id
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  instance_class            = var.db_instance_class
  multi_az                  = var.multi_az
}

module "elasticache" {
  source                    = "./modules/elasticache"
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  allowed_security_group_id = module.app_asg.security_group_id
  node_type                 = var.redis_node_type
  num_cache_clusters        = var.redis_num_cache_clusters
}