output "vpc_id" {
  description = "ID of project VPC"
  value = aws_vpc.project1.id
}

output "vpc_arn" {
  description = "arn of project VPC"
  value = aws_vpc.project1.arn
}

output "subnet1_id" {
  description = "ID of project Subnetwork"
  value = aws_subnet.project1subnet1.id
}

output "subnet2_id" {
  description = "ID of project Subnetwork"
  value = aws_subnet.project1subnet2.id
}

output "subnet1_arn" {
  description = "arn of project Subnetwork"
  value = aws_subnet.project1subnet1.arn
}

output "subnet2_arn" {
  description = "arn of project Subnetwork"
  value = aws_subnet.project1subnet2.arn
}

output "sg_id" {
  description = "ID of project Subnetwork"
  value = aws_security_group.project1sg.id
}

output "sg_arn" {
  description = "arn of project Subnetwork"
  value = aws_security_group.project1sg.arn
}

