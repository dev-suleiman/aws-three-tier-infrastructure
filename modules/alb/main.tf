
// --- Security Group ---
resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.name}-alb-sg"
  description = "Security group for ${var.name} ALB in ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.target_port
    to_port         = var.target_port
    protocol        = "tcp"
    cidr_blocks     = var.ingress_security_group_id == null ? [var.ingress_cidr] : []
    security_groups = var.ingress_security_group_id != null ? [var.ingress_security_group_id] : []
    description     = "Ingress rule"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.name}-alb-sg"
    Environment = var.environment
  }
}

// --- Target Group ---
resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-${var.name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "${var.environment}-${var.name}-tg"
    Environment = var.environment
  }
}

// --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = "${var.environment}-${var.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "${var.environment}-${var.name}-alb"
    Environment = var.environment
  }
}

// --- Listener ---
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.target_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}