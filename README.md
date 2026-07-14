
# AWS Three-Tier Infrastructure
## Architecture

The infrastructure follows a three-tier model deployed across two Availability Zones:

- **Presentation tier** : internet-facing Application Load Balancer routes traffic to web servers in private subnets
- **Application tier** : internal Application Load Balancer routes traffic from web servers to app servers in private subnets
- **Data tier** : PostgreSQL RDS instance in isolated database subnets, with ElastiCache Redis alongside the app tier for caching

No EC2 instance in any tier has a public IP address. The only entry point is the public ALB DNS name.

---

## Infrastructure Components

| Component | Description |
|---|---|
| **VPC** | Custom VPC with 6 subnets across 2 AZs — public, private, and database |
| **Internet Gateway** | Entry point for public internet traffic |
| **NAT Gateway** | Outbound internet access for private subnet instances |
| **Public ALB** | Internet-facing load balancer for the web tier |
| **Web ASG** | Auto Scaling Group running nginx web servers |
| **Internal ALB** | Private load balancer between web and app tiers |
| **App ASG** | Auto Scaling Group running application servers |
| **RDS PostgreSQL** | Managed relational database in isolated database subnets |
| **ElastiCache Redis** | In-memory cache for sessions and frequently accessed data |
| **S3** | Application object storage with versioning and lifecycle policies |
| **Secrets Manager** | Encrypted storage for database credentials |
| **IAM** | Least-privilege roles for web and app tier EC2 instances |

---

## Network Layout

```
10.0.0.0/16  VPC

Public Subnets          10.0.1.0/24  (eu-north-1a)   NAT Gateway
                        10.0.2.0/24  (eu-north-1b)   NAT Gateway

Private Web Subnets     10.0.3.0/24  (eu-north-1a)   Web ASG instances
                        10.0.4.0/24  (eu-north-1b)   Web ASG instances

Private App Subnets     10.0.5.0/24  (eu-north-1a)   App ASG instances
                        10.0.6.0/24  (eu-north-1b)   App ASG instances

Database Subnets        10.0.7.0/24  (eu-north-1a)   RDS Primary
                        10.0.8.0/24  (eu-north-1b)   RDS Standby
```

---

## Security Model

Security groups are chained with each layer accepting only traffic from the layer directly above it:

```
Internet
  → Public ALB SG       (allows 0.0.0.0/0 on port 80)
  → Web ASG SG          (allows Public ALB SG only)
  → Internal ALB SG     (allows Web ASG SG only)
  → App ASG SG          (allows Internal ALB SG only)
  → RDS SG              (allows App ASG SG on port 5432 only)
  → ElastiCache SG      (allows App ASG SG on port 6379 only)
```

No CIDR-based rules between internal layers — all internal access is security group to security group.

---

## Module Structure

```
aws-three-tier-infrastructure/
├── modules/
│   ├── vpc/           
│   ├── alb/            
│   ├── asg/            
│   ├── rds/            
│   ├── elasticache/    
│   ├── iam/            
│   ├── secrets/        
│   └── s3/             
├── main.tf             
├── providers.tf        
├── variables.tf        
├── outputs.tf          
└── terraform.tfvars.example
```

The `alb` and `asg` modules are each called twice ie. once per tier, with different inputs.
---

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.5
- An S3 bucket for remote state storage (see bootstrap instructions below)
- An SSH key pair generated locally

---

## Bootstrap Remote State

Before deploying the main infrastructure, create the S3 bucket for Terraform remote state:

```bash
aws s3api create-bucket \
  --bucket your-name-terraform-state \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

aws s3api put-bucket-versioning \
  --bucket your-name-terraform-state \
  --versioning-configuration Status=Enabled
```

Then update the `bucket` value in `providers.tf` to match.

---

## Deployment

**1. Clone the repository:**

```bash
git clone https://github.com/dev-suleiman/aws-three-tier-infrastructure.git
cd aws-three-tier-infrastructure
```

**2. Generate an SSH key pair:**

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/three-tier-key
```

**3. Create your tfvars file:**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Fill in your values — region, bucket name, database credentials, key path.

**4. Initialise and deploy:**

```bash
terraform init
terraform plan
terraform apply
```

**5. Access the application:**

```bash
terraform output web_alb_dns_name
```

Open the DNS name in a browser to confirm the web tier is serving traffic.

---

## Teardown

RDS has deletion protection enabled. Disable it before destroying:

```hcl
# In modules/rds/main.tf
deletion_protection = false
```

Then apply and destroy:

```bash
terraform apply   # applies the deletion_protection change
terraform destroy
```

---

## Key Design Decisions

**One ALB module, two deployments** : the ALB module accepts an `internal` boolean and either a CIDR or security group ID for ingress. The same code produces both the public web ALB and the private app ALB with different inputs.

**One ASG module, two tiers** : same pattern. The web tier runs nginx; the app tier runs whatever the application stack requires. User data is passed as a variable so the module stays generic.

**IAM roles scoped to specific ARNs** : the app tier role's Secrets Manager permission is locked to the specific secret ARN, not `*`. The S3 permission is locked to the specific bucket ARN. Permissions are granted only where they're needed.

**Remote state with locking** : Terraform state lives in S3 with native lock file support (`use_lockfile = true`). No DynamoDB table required with provider version 5+.

**Security group chaining over CIDR rules** : internal traffic between tiers uses security group references, not IP ranges. This means rules stay valid even as instances are replaced by the ASG and get new private IPs.

---

## Outputs

After a successful apply:

| Output | Description |
|---|---|
| `web_alb_dns_name` | Public entry point, open in browser to reach the web tier |
| `app_alb_dns_name` | Internal ALB DNS is reachable only from within the VPC |
| `db_endpoint` | RDS connection endpoint including port |
| `db_host` | RDS hostname for application configuration |
| `redis_endpoint` | ElastiCache Redis primary endpoint |
| `db_secret_arn` | Secrets Manager ARN for database credentials |
| `web_asg_name` | Web tier ASG name for monitoring and scaling operations |
| `app_asg_name` | App tier ASG name for monitoring and scaling operations |
| `bucket_name` | S3 application bucket name |

---

## Author

**Suleiman Baba Mohammed**

[GitHub](https://github.com/dev-suleiman) · [LinkedIn](https://www.linkedin.com/in/suleiman-baba-mohammed-0179a824b/)