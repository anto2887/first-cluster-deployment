resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.project-12.id
  tags = {
    Name        = "${var.app_name}-igw"
  }

}

resource "aws_subnet" "private_net" {
  vpc_id            = aws_vpc.project-12.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public_net" {
  vpc_id                  = aws_vpc.project-12.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "project-12-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project-12.id

  tags = {
    Name        = "project-12-routing-table-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_net.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.project-12.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
  }
}
