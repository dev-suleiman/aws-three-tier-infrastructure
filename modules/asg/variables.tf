variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "name" {
  description = "Name identifier for this ASG — web or app"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch instances in"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to the public key for SSH access"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile to attach to instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register instances with"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB that sends traffic to this tier"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to instances — used for app tier to reach RDS and Redis"
  type        = list(string)
  default     = []
}