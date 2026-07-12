// --- Security Group ---
resource "aws_security_group" "redis" {
  name        = "${var.environment}-redis-sg"
  description = "Allow Redis traffic from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from app tier only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-redis-sg"
    Environment = var.environment
  }
}

// --- Cache Subnet Group ---
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.environment}-redis-subnet-group"
  description = "Redis subnet group for ${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

// --- Redis Parameter Group ---
resource "aws_elasticache_parameter_group" "main" {
  name        = "${var.environment}-redis-params"
  family      = "redis7"
  description = "Redis 7 parameter group for ${var.environment}"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

// --- Redis Replication Group ---
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.environment}-redis"
  description          = "Redis cluster for ${var.environment}"

  node_type          = var.node_type
  port               = 6379
  num_cache_clusters = var.num_cache_clusters

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]
  parameter_group_name = aws_elasticache_parameter_group.main.name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  automatic_failover_enabled = var.num_cache_clusters > 1 ? true : false

  tags = {
    Name        = "${var.environment}-redis"
    Environment = var.environment
  }
}