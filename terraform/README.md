# Load Test Infrastructure - Terraform

Modular Terraform infrastructure for the load-test application on AWS.

## Structure

```
terraform/
├── modules/
│   └── vpc/              # Reusable VPC module
├── environments/
│   └── sandbox/          # Sandbox environment configuration
├── provider.tf           # AWS provider configuration
└── versions.tf           # Terraform and provider version constraints
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- AWS CLI configured with appropriate credentials
- AWS account access

### Initialize and Deploy

```bash
# Navigate to the sandbox environment
cd terraform/environments/sandbox

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply

# View outputs
terraform output
```

## Environments

### Sandbox

Cost-optimized configuration for development and testing:
- VPC: 10.0.0.0/24 (256 IPs)
- 2 Availability Zones
- Single NAT Gateway (cost optimization)
- Public and private subnets

**Estimated Monthly Cost**: ~$35-40 (primarily NAT Gateway)

## Adding New Environments

To add a new environment (e.g., production):

```bash
# Create new environment directory
mkdir -p terraform/environments/production

# Copy sandbox configuration as template
cp terraform/environments/sandbox/*.tf terraform/environments/production/
cp terraform/environments/sandbox/terraform.tfvars terraform/environments/production/

# Update values in terraform.tfvars for production settings
```

## Modules

### VPC Module

Creates a complete VPC with:
- Public subnets for load balancers
- Private subnets for application servers
- Internet Gateway for public internet access
- NAT Gateway for private subnet outbound connectivity
- Route tables and associations

See [modules/vpc/README.md](modules/vpc/README.md) for detailed documentation.

## Modules

### VPC Module
See [modules/vpc/README.md](modules/vpc/README.md)

### ECR Module
See [modules/ecr/README.md](modules/ecr/README.md)

## Next Steps

Future modules to add:
- **EC2**: Application servers
- **IAM**: Roles and policies for EC2
- **Security Groups**: Network access control
- **ALB**: Application load balancer
- **ECS**: Container orchestration (alternative to EC2)

## Commands Reference

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Show current state
terraform show
```

## Notes

- Terraform state is currently stored locally
- For team collaboration, configure S3 backend in `backend.tf`
- All resources are tagged with environment and project information
- DNS support and hostnames are enabled in the VPC
