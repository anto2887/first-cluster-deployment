resource "docker_image" "nginx_image" {
  name = "nginxdemos/hello"
}
resource "aws_ecr_repository" "aws-project-ecr" {
  name = "aws-project-ecr"
}