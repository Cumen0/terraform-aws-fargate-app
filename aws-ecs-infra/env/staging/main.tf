module "ecr" {
  source = "../../modules/ecr"

  ecr_repository_name = "${var.project_name}-${var.env}-repo"
}

module "vpc" {
  source = "../../modules/network"

  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  env               = var.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  env          = var.env
  aws_region   = var.aws_region

  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn

  image_url = "${module.ecr.repository_url}:latest"
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  env          = var.env
}
