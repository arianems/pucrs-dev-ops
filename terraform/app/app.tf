# Sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name = var.aws_ecs_cluster
}

data "aws_lb_target_group" "app" {
  name = "${var.app_name}-tg"
}

data "aws_security_group" "ecs" {
  filter {
    name   = "group-name"
    values = ["${var.app_name}-ecs-sg"]
  }

  vpc_id = data.aws_vpc.default.id
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRoleNew"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/blazor-app-task"
        "awslogs-create-group"  = "true"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = var.aws_ecs_service
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [data.aws_security_group.ecs.id]
    assign_public_ip = true
  }
  
  load_balancer {
  target_group_arn = data.aws_lb_target_group.app.arn
  container_name   = var.app_name
  container_port   = 8080
  }
}