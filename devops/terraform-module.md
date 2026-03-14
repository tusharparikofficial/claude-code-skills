# Terraform Module Generator

Create a Terraform module following best practices for AWS infrastructure resources.

## Arguments

$ARGUMENTS - Resource type: `vpc`, `rds`, `ecs`, `s3`, `lambda`, or `cloudfront`

## Instructions

1. **Parse the resource type** from `$ARGUMENTS`:
   - `vpc` - VPC with public/private subnets, NAT Gateway, flow logs
   - `rds` - RDS database (PostgreSQL/MySQL) with encryption, backups, monitoring
   - `ecs` - ECS Fargate service with ALB, auto-scaling, logging
   - `s3` - S3 bucket with versioning, encryption, lifecycle policies
   - `lambda` - Lambda function with API Gateway, IAM role, logging
   - `cloudfront` - CloudFront distribution with S3 or ALB origin
   - If not provided or unrecognized, ask the user which resource they need.

2. **Create the module directory** at `terraform/<resource-type>/` (or `modules/<resource-type>/` if a `modules/` dir already exists).

3. **Generate the following files**:

### `main.tf`

Provider and resource definitions following these practices:
- Use `terraform { required_version }` constraint
- Use `required_providers` with version constraints
- Use `locals` block for computed values and naming conventions
- Resource naming convention: `"${var.project}-${var.environment}-<resource>"`

**VPC Module** (`vpc`):
- VPC with configurable CIDR block
- Public subnets (one per AZ, configurable count)
- Private subnets (one per AZ, configurable count)
- Internet Gateway for public subnets
- NAT Gateway (single or per-AZ, configurable) for private subnets
- Route tables for public and private subnets
- VPC Flow Logs to CloudWatch
- Default security group that denies all traffic
- VPC endpoints for S3 and DynamoDB (Gateway type)
- DNS hostnames and DNS support enabled

**RDS Module** (`rds`):
- DB subnet group using private subnets
- Security group allowing access from app security group only
- RDS instance or Aurora cluster (configurable)
- Engine: PostgreSQL or MySQL (configurable)
- Multi-AZ for production, single-AZ for dev
- Encryption at rest with KMS key
- Automated backups with configurable retention (default 7 days)
- Enhanced monitoring with IAM role
- Performance Insights enabled
- Parameter group with sensible defaults
- Final snapshot on deletion
- CloudWatch alarms for CPU, storage, connections

**ECS Module** (`ecs`):
- ECS Cluster with Container Insights
- Task Definition (Fargate) with configurable CPU/memory
- ECS Service with desired count
- Application Load Balancer with target group
- ALB security group (HTTP/HTTPS from anywhere)
- Task security group (from ALB only)
- CloudWatch Log Group for container logs
- IAM execution role and task role (least privilege)
- Auto-scaling policies (CPU and memory based)
- Health check configuration
- Service discovery (optional)

**S3 Module** (`s3`):
- S3 bucket with unique naming
- Versioning enabled (configurable)
- Server-side encryption (AES256 or KMS)
- Block all public access (configurable)
- Lifecycle rules for transitioning to cheaper storage classes
- CORS configuration (optional)
- Bucket policy for access control
- Access logging to a separate bucket (optional)
- Object lock configuration (optional)
- Replication configuration (optional)

**Lambda Module** (`lambda`):
- Lambda function with configurable runtime, handler, memory, timeout
- IAM execution role with CloudWatch Logs permissions
- CloudWatch Log Group with retention policy
- API Gateway (REST or HTTP) trigger (optional)
- Environment variables from variables
- VPC configuration (optional, for database access)
- Dead letter queue (SQS) for failed invocations
- X-Ray tracing enabled
- Reserved concurrency (configurable)
- Lambda Layer support (optional)

**CloudFront Module** (`cloudfront`):
- CloudFront distribution
- S3 origin with OAC (Origin Access Control) or ALB origin
- Default cache behavior with optimized settings
- Custom error responses (403 -> /index.html for SPAs)
- Price class (configurable, default PriceClass_100)
- Viewer protocol policy: redirect-to-https
- TLS 1.2 minimum
- ACM certificate (reference, not created)
- WAF Web ACL association (optional)
- Custom headers for origin
- Logging to S3 (optional)

### `variables.tf`

Define all input variables with:
- `description` for every variable
- `type` constraint
- `default` value where sensible (no defaults for required params)
- `validation` blocks for format/value constraints
- Common variables across all modules:
  - `project` (string) - Project name
  - `environment` (string) - Environment (dev/staging/prod)
  - `tags` (map(string)) - Additional tags
  - `aws_region` (string, default "us-east-1")

### `outputs.tf`

Export useful values:
- Resource IDs, ARNs, endpoints
- Connection strings (for databases)
- URLs (for load balancers, CloudFront)
- Security group IDs
- IAM role ARNs

### `terraform.tfvars.example`

Example variable values with comments explaining each:
```hcl
# Project Configuration
project     = "myapp"
environment = "dev"

# Resource-specific examples...
```

### `versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state
  # backend "s3" {
  #   bucket         = "myapp-terraform-state"
  #   key            = "<resource-type>/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
```

4. **Apply consistent tagging** across all resources:
```hcl
tags = merge(var.tags, {
  Project     = var.project
  Environment = var.environment
  ManagedBy   = "terraform"
  Module      = "<resource-type>"
})
```

5. **IAM best practices**:
- Use least privilege for all IAM policies
- Use specific resource ARNs instead of `*` where possible
- Use managed policies where available
- Include `condition` blocks for extra security

6. **Write all files** to the module directory.

7. **Print a summary** with:
   - Files generated and their locations
   - Resources that will be created
   - Required variables that must be set
   - How to initialize: `cd terraform/<resource-type> && terraform init`
   - How to plan: `terraform plan -var-file=terraform.tfvars`
   - How to apply: `terraform apply -var-file=terraform.tfvars`
   - Cost considerations (NAT Gateway, RDS, etc.)
   - Recommended remote state configuration
   - Security considerations and next steps
