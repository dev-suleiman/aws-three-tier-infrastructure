output "web_tier_instance_profile_name" {
  description = "Instance profile name for web tier EC2 instances"
  value       = aws_iam_instance_profile.web_tier.name
}

output "app_tier_instance_profile_name" {
  description = "Instance profile name for app tier EC2 instances"
  value       = aws_iam_instance_profile.app_tier.name
}

output "web_tier_role_arn" {
  description = "ARN of the web tier IAM role"
  value       = aws_iam_role.web_tier.arn
}

output "app_tier_role_arn" {
  description = "ARN of the app tier IAM role"
  value       = aws_iam_role.app_tier.arn
}