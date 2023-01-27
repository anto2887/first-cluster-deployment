resource "aws_vpc" "project-12" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project-12"
  }
}