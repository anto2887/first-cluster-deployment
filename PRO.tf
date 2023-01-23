resource "aws_ecs_task_definition" "proj12" {
  family = "service"
  container_definitions = jsonencode([
        {
      name      = "proj12"
      image     = "docker.io/nginxdemos/hello"
      cpu       = 1
      memory    = 1000
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}