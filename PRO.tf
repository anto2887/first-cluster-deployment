resource "aws_ecs_task_definition" "project1td" {
  family = "service"
  container_definitions = jsonencode([
        {
      name      = "project1td"
      image     = "docker.io/nginxdemos/hello"
#      cpu       =
      memory    = 128
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

resource "aws_vpc" "project1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project1.id
}

resource "aws_subnet" "project1subnet1" {
  vpc_id     = aws_vpc.project1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.project1]
  }

resource "aws_subnet" "project1subnet2" {
  vpc_id     = aws_vpc.project1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.project1]
}

resource "aws_security_group" "project1sg" {
  name        = "project1sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.project1.id

  ingress {
    description      = " HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Open Traffic from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "project1alb" {
  name               = "project1alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project1sg.id]
  subnet_mapping {
    subnet_id = aws_subnet.project1subnet1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.project1subnet2.id
  }
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "project1tg" {
    name     = "project1tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.project1.id
    depends_on = [aws_lb.project1alb]
}


resource "aws_lb_listener" "project1alblist" {
  load_balancer_arn = aws_lb.project1alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project1tg.arn
  }
}

resource "aws_launch_template" "project1lt" {
  name_prefix   = "project1lt"
  image_id      = "ami-05e7fa5a3b6085a75"
  instance_type = "t2.medium"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 80
    }
  }
}

resource "aws_autoscaling_group" "project1asg" {
  name                      = "project1asg"
  max_size                  = 2
  min_size                  = 1
#   health_check_grace_period = 20000
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = false
  vpc_zone_identifier       = [aws_subnet.project1subnet1.id, aws_subnet.project1subnet2.id]
  target_group_arns          = [aws_lb_target_group.project1tg.arn]
  launch_template {
    id      = aws_launch_template.project1lt.id
    version = "$Latest"
  }
}

# Creating the autoscaling policy of the autoscaling group
resource "aws_autoscaling_policy" "prj1asgpolicy" {
  name                   = "prj1asgpolicy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.project1asg.name
}


resource "aws_ecs_cluster" "project1cluster" {
  name = "project1cluster"
}
resource "aws_ecs_capacity_provider" "project1cp" {
  name = "project1cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.project1asg.arn
  }
}

resource "aws_ecs_service" "project1svc" {
  name            = "project1svc"
  cluster         = aws_ecs_cluster.project1cluster.id
  task_definition = aws_ecs_task_definition.project1td.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.project1tg.arn
    container_name   = "project1td"
    container_port   = 80
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}

# resource "aws_ecs_task_set" "project1ts" {
#   service         = aws_ecs_service.project1svc.id
#   cluster         = aws_ecs_cluster.project1cluster.id
#   task_definition = aws_ecs_task_definition.project1td.arn
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.project1tg.arn
#     container_name   = "project1td"
#     container_port   = 80
#   }
# }
#