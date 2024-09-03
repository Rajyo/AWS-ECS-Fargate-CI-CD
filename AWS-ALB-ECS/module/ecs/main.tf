variable "iam_role_arn" {}
variable "DOCKER_IMAGE" {}
variable "DOCKER_PORT" {}
variable "private_subnet_id" {}
variable "security_group_id" {}
variable "lb_tg_arn" {}


output "ecs_cluster_name" {
  value = aws_ecs_cluster.web_server_cluster.name  
}

output "ecs_service_name" {
  value = aws_ecs_service.web_server_service.name
}


resource "aws_ecs_cluster" "web_server_cluster" {
  name = "aws_web_server_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.web_server_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "web_server_task" {
  family                   = "aws-cql-web-server-task"
  task_role_arn            = var.iam_role_arn
  execution_role_arn       = var.iam_role_arn
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name   = "aws-cql-web-server-container"
      image  = var.DOCKER_IMAGE
      cpu    = 1024
      memory = 2048
      portMappings = [
        {
          containerPort = var.DOCKER_PORT
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "web_server_service" {
  name             = "aws-cql-web-server-service"
  cluster          = aws_ecs_cluster.web_server_cluster.id
  task_definition  = aws_ecs_task_definition.web_server_task.arn
  platform_version = "LATEST"
  desired_count    = 1

  network_configuration {
    subnets          = var.private_subnet_id
    security_groups  = [ var.security_group_id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.lb_tg_arn
    container_name   = "aws-cql-web-server-container"
    container_port   = var.DOCKER_PORT
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 0
    weight            = 1
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_ecs_task_definition.web_server_task]
}