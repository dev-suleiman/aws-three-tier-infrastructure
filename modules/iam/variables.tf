variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the app tier is allowed to access"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for database credentials"
  type        = string
}