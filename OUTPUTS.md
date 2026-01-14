# Terraform Outputs Guide

## View All Outputs

### Quick View (Formatted)
```bash
./scripts/show-outputs.sh
```

### All Outputs (Raw)
```bash
cd terraform/environments/sandbox
terraform output
```

### Specific Outputs
```bash
cd terraform/environments/sandbox

# VPC
terraform output vpc_id
terraform output vpc_cidr_block
terraform output public_subnet_ids
terraform output private_subnet_ids

# Networking
terraform output internet_gateway_id
terraform output nat_gateway_ids
terraform output nat_gateway_public_ips

# ECR
terraform output ecr_repository_url
terraform output ecr_repository_name
terraform output ecr_registry_id

# IAM
terraform output iam_user_name
terraform output iam_user_arn
terraform output iam_access_key_id

# Secret (sensitive)
terraform output -raw iam_access_key_secret

# Full Summary
terraform output infrastructure_summary
```

## Apply and View Outputs

```bash
cd terraform/environments/sandbox

# Apply infrastructure
terraform apply

# View all outputs
terraform output

# Or use the helper script
cd ../../..
./scripts/show-outputs.sh
```

## Setup GitHub Secrets

After applying Terraform:

```bash
cd terraform/environments/sandbox

# Get values
ACCESS_KEY_ID=$(terraform output -raw iam_access_key_id)
ACCESS_KEY_SECRET=$(terraform output -raw iam_access_key_secret)
ECR_URL=$(terraform output -raw ecr_repository_url)

# Set in GitHub (requires gh CLI)
gh secret set AWS_ACCESS_KEY_ID --body "$ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "$ACCESS_KEY_SECRET"

# Verify
gh secret list
```

## Output Details

### VPC Outputs
- **vpc_id**: VPC identifier
- **vpc_cidr_block**: CIDR range (10.0.0.0/24)
- **public_subnet_ids**: List of public subnet IDs
- **private_subnet_ids**: List of private subnet IDs

### Networking Outputs
- **internet_gateway_id**: IGW for public internet access
- **nat_gateway_ids**: NAT gateway IDs
- **nat_gateway_public_ips**: Elastic IPs for NAT gateways
- **public_route_table_id**: Public route table
- **private_route_table_ids**: Private route tables

### ECR Outputs
- **ecr_repository_url**: Full URL for docker push (e.g., 123456789.dkr.ecr.us-east-1.amazonaws.com/load-test)
- **ecr_repository_name**: Repository name (load-test)
- **ecr_repository_arn**: ARN for IAM policies
- **ecr_registry_id**: AWS account ID

### IAM Outputs
- **iam_user_name**: GitHub Actions user name
- **iam_user_arn**: User ARN
- **iam_access_key_id**: Access key (public, add to GitHub secrets)
- **iam_access_key_secret**: Secret key (sensitive, add to GitHub secrets)

### Infrastructure Summary
Combined output showing all resources in structured format.

## Sensitive Outputs

The IAM secret access key is marked as sensitive. To view:

```bash
terraform output -raw iam_access_key_secret
```

⚠️ **Warning**: Only shown once! Save this value immediately.

## Export to File

```bash
cd terraform/environments/sandbox

# All outputs to JSON
terraform output -json > outputs.json

# Specific output
terraform output -raw ecr_repository_url > ecr_url.txt

# For use in scripts
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR URL: $ECR_URL"
```

## Troubleshooting

### Output not found
```
Error: Output not found
```

**Solution**: Run `terraform apply` first to create resources.

### Sensitive output hidden
```
(sensitive value)
```

**Solution**: Use `-raw` flag:
```bash
terraform output -raw iam_access_key_secret
```

### Module not initialized
```
Error: Module not installed
```

**Solution**:
```bash
terraform init
terraform apply
```
