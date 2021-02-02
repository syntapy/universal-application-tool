provider "aws" {
  #version = "~> 2.0"
  region  = "us-west-1" # Setting my region to London. Use your own region here
}

# INFRASTRUCTURE
resource "aws_ecr_repository" "postgres" {
  name = "postgres" # Naming my repository
}

resource "aws_ecr_repository" "uat" {
  name = "uat" # Naming my repository
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "main_cluster" # Naming the cluster
}

# NETWORKS
resource "aws_default_vpc" "default_vpc" {
}

# 
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-west-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-west-1b"
}

# TASKS / IAM
resource "aws_ecs_task_definition" "main_task" {
  family                   = "main_task" #
  container_definitions    = <<DEFINITION
  [
    {
      "name": "uat_task",
      "image": "${aws_ecr_repository.uat.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9000,
          "hostPort": 9000
        }
      ],
      "memory": 1024,
      "cpu": 256
    },
    {
      "name": "postgres_task",
      "image": "${aws_ecr_repository.postgres.repository_url}",
      "essential": true,
      "portMappings": [
        {
         "containerPort": 5432
        }
      ],
      "environment": [
        {"name": "POSTGRES_PASSWORD", "value":"example"}
      ],
      "memory": 1024,
      "cpu": 256
    }

  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 2048        # Specifying the memory our container requires
  cpu                      = 512         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_ecs_service" "uat_service" {
  name            = "uat_service"
  cluster         = "${aws_ecs_cluster.main_cluster.id}"
  task_definition = "${aws_ecs_task_definition.main_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# LOAD BALANCER
resource "aws_alb" "application_load_balancer" {
  name               = "uat-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
