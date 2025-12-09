# --- CloudWatch Logs ---
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.project_name}-${var.env}"
  retention_in_days = 7
}

# --- IAM Role (Execution Role) ---
resource "aws_iam_role" "ecs_execution_role" {
  name_prefix = "${var.project_name}-${var.env}-exec-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Task Role ---
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.env}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "*"
      }
    ]
  })
}

# --- Security Group for Fargate Tasks ---
resource "aws_security_group" "ecs_tasks_sg" {
  name_prefix = "${var.project_name}-${var.env}-ecs-tasks-sg-"
  description = "Allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [var.alb_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.env}-ecs-tasks-sg"
  }
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.env}-cluster"
}

# --- Task Definition ---
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.env}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }

      ]
      environment = [
        {
          name  = "DYNAMODB_TABLE"
          value = "${var.project_name}-${var.env}-table"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# --- ECS Service ---
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.env}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-container"
    container_port   = 5000
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution_role_policy]
}
