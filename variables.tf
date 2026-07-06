variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}
