output "web_alb_dns_name" {
  description = "DNS name of the internet-facing web ALB — this is your application's entry point"
  value       = module.web_alb.alb_dns_name
}

output "app_alb_dns_name" {
  description = "DNS name of the internal app ALB"
  value       = module.app_alb.alb_dns_name
}

output "db_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.db_endpoint
}

output "db_host" {
  description = "RDS hostname"
  value       = module.rds.db_host
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.elasticache.redis_endpoint
}

output "bucket_name" {
  description = "Name of the S3 application bucket"
  value       = module.s3.bucket_name
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret in Secrets Manager"
  value       = module.secrets.db_secret_arn
}

output "web_asg_name" {
  description = "Name of the web tier Auto Scaling Group"
  value       = module.web_asg.asg_name
}

output "app_asg_name" {
  description = "Name of the app tier Auto Scaling Group"
  value       = module.app_asg.asg_name
}