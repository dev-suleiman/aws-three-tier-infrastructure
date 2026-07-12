variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB — public for web tier, private for app tier"
  type        = list(string)
}

variable "internal" {
  description = "Set to true for internal ALB, false for internet-facing"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name identifier for this ALB — used to distinguish web from app tier"
  type        = string
}

variable "target_port" {
  description = "Port the target instances are listening on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path the ALB uses for health checks"
  type        = string
  default     = "/"
}

variable "ingress_cidr" {
  description = "CIDR block allowed to reach this ALB — used for internet-facing ALB only"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_security_group_id" {
  description = "Security group allowed to reach this ALB — used for internal ALB only"
  type        = string
  default     = null
}