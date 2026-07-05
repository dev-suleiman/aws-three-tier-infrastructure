# AWS Three-Tier Infrastructure

Production-grade three-tier architecture on AWS provisioned with Terraform.

## Architecture
Internet → ALB (public subnets)
→ Web ASG (private subnets)
→ Internal ALB
→ App ASG (private subnets)
→ RDS PostgreSQL (database subnets)
→ ElastiCache Redis (private subnets)

## Infrastructure Components

- **VPC** — custom VPC with public, private, and database subnets across 2 AZs
- **ALB** — internet-facing application load balancer
- **Web ASG** — auto scaling group for web tier with target tracking scaling
- **Internal ALB** — internal load balancer between web and app tier
- **App ASG** — auto scaling group for application tier
- **RDS** — PostgreSQL database in isolated database subnets
- **ElastiCache** — Redis cluster for session and data caching
- **IAM** — least privilege roles for EC2 instances
- **Secrets Manager** — secure storage for database credentials

## Prerequisites

- AWS CLI configured
- Terraform >= 5.0
- An S3 bucket for remote state

## Usage

1. Clone the repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values
3. Update the backend bucket name in `providers.tf`
4. Run:

```bash
terraform init
terraform plan
terraform apply
```

## Author

Suleiman Baba Mohammed — [GitHub](https://github.com/dev-suleiman)