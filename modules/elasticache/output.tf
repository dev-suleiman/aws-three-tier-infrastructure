output "redis_endpoint" {
  description = "Primary endpoint for the Redis cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Port the Redis cluster is listening on"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_security_group_id" {
  description = "Security group ID of the Redis cluster"
  value       = aws_security_group.redis.id
}