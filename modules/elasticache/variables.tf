variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group ID of the app tier — only source allowed to reach Redis"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters — 1 for dev, 2+ for production"
  type        = number
  default     = 1
}