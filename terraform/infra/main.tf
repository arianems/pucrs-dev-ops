provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecr_repository" "app" {
  name                 = var.aws_ecr_repository
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRoleNew"
}

# EC2 Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-sg"
  description = "Security group for ECS app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow app traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

# Load Balancer
resource "aws_lb" "app" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.ecs.id
  ]

  subnets = data.aws_subnets.default.ids
}

# EC2 Target Group
resource "aws_lb_target_group" "app" {
  name             = "${var.app_name}-tg"
  port             = 8080
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  target_type      = "ip"
  ip_address_type  = "ipv4"

  vpc_id = data.aws_vpc.default.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.aws_ecs_cluster
}