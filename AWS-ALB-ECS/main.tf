module "vpc" {
  source               = "./module/vpc"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr  = var.public_subnets_cidr
}

module "sg" {
  source      = "./module/sg"
  vpc_id      = module.vpc.vpc_id
  DOCKER_PORT = var.DOCKER_PORT
  vpc_cidr    = var.vpc_cidr
}

module "iam" {
  source = "./module/iam"
}

module "ecs" {
  source            = "./module/ecs"
  iam_role_arn      = module.iam.iam_role_arn
  DOCKER_IMAGE      = var.DOCKER_IMAGE
  DOCKER_PORT       = var.DOCKER_PORT
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = module.sg.security_group_id
  lb_tg_arn         = module.alb.lb_tg_arn
}

module "asg" {
  source           = "./module/asg"
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
}

module "alb" {
  source            = "./module/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  security_group_id = module.sg.security_group_id
}
