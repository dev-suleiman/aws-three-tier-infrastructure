variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

// --- EC2 ---
variable "instance_type" {
  description = "EC2 instance type for all tiers"
  type        = string
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to the public key for SSH access"
  type        = string
}

// --- Web Tier Scaling ---
variable "web_min_size" {
  description = "Minimum number of web tier instances"
  type        = number
  default     = 1
}

variable "web_max_size" {
  description = "Maximum number of web tier instances"
  type        = number
  default     = 4
}

variable "web_desired_capacity" {
  description = "Desired number of web tier instances"
  type        = number
  default     = 2
}

// --- App Tier Scaling ---
variable "app_min_size" {
  description = "Minimum number of app tier instances"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of app tier instances"
  type        = number
  default     = 4
}

variable "app_desired_capacity" {
  description = "Desired number of app tier instances"
  type        = number
  default     = 2
}

// --- Database ---
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

// --- ElastiCache ---
variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis cache clusters"
  type        = number
  default     = 1
}

// --- S3 ---
variable "bucket_name" {
  description = "Name of the S3 application bucket"
  type        = string
}