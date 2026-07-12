// modules/asg/main.tf

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// --- Key Pair ---
resource "aws_key_pair" "main" {
  key_name   = "${var.environment}-${var.name}-key"
  public_key = file(var.public_key_path)
}

// --- Security Group ---
resource "aws_security_group" "main" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for ${var.name} tier in ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.name}-sg"
    Environment = var.environment
  }
}

// --- Launch Template ---
resource "aws_launch_template" "main" {
  name_prefix   = "${var.environment}-${var.name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name

  vpc_security_group_ids = concat(
    [aws_security_group.main.id],
    var.additional_security_group_ids
  )

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = var.user_data != "" ? base64encode(var.user_data) : null

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-${var.name}-instance"
      Environment = var.environment
      Tier        = var.name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

// --- Auto Scaling Group ---
resource "aws_autoscaling_group" "main" {
  name                = "${var.environment}-${var.name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = var.name
    propagate_at_launch = true
  }
}

// --- Target Tracking Scaling Policy ---
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.environment}-${var.name}-cpu-tracking"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}