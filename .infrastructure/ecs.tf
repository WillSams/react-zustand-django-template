resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = var.function_name
    image     = "${aws_ecr_repository.this.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    # WARNING: DJANGO_SECRET_KEY is in plaintext here.
    # For production, store it in AWS Secrets Manager and reference it via the `secrets` key.
    environment = [
      { name = "ENVIRONMENT",            value = var.environment },
      { name = "DJANGO_SETTINGS_MODULE", value = "app.settings" },
      { name = "DJANGO_SECRET_KEY",      value = var.django_secret_key },
      { name = "DEBUG",                  value = "False" },
      { name = "ALLOWED_HOSTS",          value = var.allowed_hosts },
      { name = "CORS_ALLOWED_ORIGINS",   value = join(",", var.allowed_origins) },
      { name = "ABOUT_MESSAGE",          value = var.about_message },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.function_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}
