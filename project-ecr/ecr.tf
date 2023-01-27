resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

resource "aws_ecr_repository" "aws-project-ecr" {
  name = "aws-project-ecr"
}