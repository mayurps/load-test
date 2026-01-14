# Environment Setup Guide

Complete guide for setting up the load-test infrastructure from scratch.

## Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Docker](https://www.docker.com/get-started) >= 20.10
- Git

### Required Access
- AWS account with appropriate permissions
- GitHub repository with Actions enabled

---

## Part 1: AWS Setup

### 1.1 Configure AWS Credentials

**Option A: Using AWS CLI (Recommended)**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region: us-east-1
# Enter default output format: json
```

**Option B: Using Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_REGION="us-east-1"
```

**Option C: Using AWS Profile**
```bash
# Configure a named profile
aws configure --profile sandbox

# Use the profile
export AWS_PROFILE=sandbox
```

### 1.2 Verify AWS Access
```bash
aws sts get-caller-identity
```

---

## Part 2: Terraform Infrastructure Deployment

### 2.1 Navigate to Sandbox Environment
```bash
cd terraform/environments/sandbox
```

### 2.2 Initialize Terraform
```bash
terraform init
```

### 2.3 Review Configuration
```bash
# See what will be created
terraform plan
```

Expected resources:
- VPC with CIDR 10.0.0.0/24
- 2 public subnets
- 2 private subnets
- Internet Gateway
- NAT Gateway (1 for cost optimization)
- Route tables
- ECR repository
- IAM user with ECR permissions
- Access keys for GitHub Actions

### 2.4 Apply Configuration
```bash
terraform apply
```

Type `yes` when prompted.

**Expected time**: 2-3 minutes

### 2.5 Save Outputs
```bash
# Get all outputs
terraform output

# Get specific values
terraform output iam_access_key_id

# Get secret access key (sensitive - only shown once)
terraform output -raw iam_access_key_secret
```

**The IAM user and credentials are automatically created by Terraform!**

---

## Part 3: GitHub Actions Setup

### 3.1 Get Credentials from Terraform

**Option A: Using the Setup Script (Easiest)**
```bash
# From the project root
./scripts/setup-github-secrets.sh
```

This will display the exact commands to set your GitHub secrets.

**Option B: Manual Retrieval**
```bash
cd terraform/environments/sandbox

# Get access key ID
terraform output -raw iam_access_key_id

# Get secret access key
terraform output -raw iam_access_key_secret
```

**Save the Access Key ID and Secret Access Key** - you'll need them for GitHub secrets.

### 3.2 Configure GitHub Secrets

Go to your GitHub repository:
1. Click **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret**
3. Add the following secrets:

| Secret Name | Value |
|------------|-------|
| `AWS_ACCESS_KEY_ID` | From IAM user creation step |
| `AWS_SECRET_ACCESS_KEY` | From IAM user creation step |

### 3.3 Verify Workflow File

The workflow file is already created at `.github/workflows/push-to-ecr.yml`

### 3.4 Trigger First Build

```bash
# Commit and push to trigger the workflow
git add .
git commit -m "Add ECR infrastructure and GitHub Actions workflow"
git push origin main
```

Go to **Actions** tab in GitHub to see the workflow running.

---

## Part 4: Manual Docker Oper`terraform output -raw iam_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | From `terraform output -raw iam_access_key_secret` |

**Using GitHub CLI (faster)**:
```bash
# After running terraform apply
cd terraform/environments/sandbox

gh secret set AWS_ACCESS_KEY_ID --body "$(terraform output -raw iam_access_key_id)"
gh secret set AWS_SECRET_ACCESS_KEY --body "$(terraform output -raw iam_access_key_secret)"
```
### 4.1 Authenticate Docker with ECR
```bash
# Get ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ${ECR_URL%/*}
```

### 4.2 Build and Push Manually
```bash
# Build the image
docker build -t load-test:latest .

# Tag the image
docker tag load-test:latest $ECR_URL:latest
docker tag load-test:latest $ECR_URL:v1.0.0

# Push to ECR
docker push $ECR_URL:latest
docker push $ECR_URL:v1.0.0
```

### 4.3 Pull and Run
```bash
# Pull from ECR
docker pull $ECR_URL:latest

# Run the container
docker run -d -p 8080:8080 $ECR_URL:latest

# Test the server
curl http://localhost:8080
```

---

## Part 5: Destroying and Recreating

### 5.1 Destroy Infrastructure
```bash
cd terraform/environments/sandbox

# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

Type `yes` when prompted.

**Important**: ECR repository might fail to destroy if it contains images. To force delete:
```bash
# List images
aws ecr list-images --repository-name load-test --region us-east-1

# Delete all images
aws ecr batch-delete-image \
  --repository-name load-test \
  --region us-east-1 \
  --image-ids "$(aws ecr list-images --repository-name load-test --region us-east-1 --query 'imageIds[*]' --output json)"

# Then retry destroy
terraform destroy
```

### 5.2 Recreate from Scratch

Simply run the deployment steps again:
```bash
cd terraform/environments/sandbox
terraform init
terraform plan
terraform apply
```

All resources will be recreated with the same configuration.

---

## Part 6: Cost Management

### 6.1 Current Monthly Costs (Sandbox)

| Resource | Monthly Cost |
|----------|-------------|
| NAT Gateway (1) | ~$32 |
| NAT Gateway Data | ~$0.045/GB |
| ECR Storage | ~$0.10/GB/month |
| VPC (free) | $0 |
| **Estimated Total** | **~$35-40/month** |

### 6.2 Cost Optimization Tips

**For development/testing**:
- Destroy infrastructure when not in use
- Use `terraform destroy` nightly via scheduled workflow
- Consider NAT instances instead of NAT Gateway

**Alternative: Auto-shutdown**
Create a cron job to destroy daily:
```yaml
# .github/workflows/nightly-destroy.yml
name: Nightly Destroy
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC daily
jobs:
  destroy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Terraform Destroy
        run: |
          cd terraform/environments/sandbox
          terraform init
          terraform destroy -auto-approve
```

---

## Part 7: Troubleshooting

### Issue: Terraform Provider Error
```
Error: No valid credential sources found
```

**Solution**: Configure AWS credentials (see Part 1.1)

### Issue: ECR Push Unauthorized
```
Error: unauthorized: authentication required
```

**Solution**: Re-authenticate Docker
```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

### Issue: GitHub Actions Failing
```
Error: AccessDenied
```

**Solution**: Verify GitHub secrets are set correctly and IAM user has proper permissions.

### Issue: Cannot Destroy ECR
```
Error: RepositoryNotEmptyException
```

**Solution**: Delete all images first (see Part 5.1)

---

## Part 8: Adding New Environments

To create a production environment:

```bash
# Create new environment directory
mkdir -p terraform/environments/production
cp -r terraform/environments/sandbox/* terraform/environments/production/

# Update terraform.tfvars
cd terraform/environments/production
vim terraform.tfvars
```

Update values for production:
```hcl
environment = "production"
vpc_cidr = "10.1.0.0/16"
single_nat_gateway = false  # Use one per AZ for HA
ecr_image_tag_mutability = "IMMUTABLE"
```

Deploy:
```bash
terraform init
terraform plan
terraform apply
```

---

## Quick Reference Commands

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy all
terraform destroy

# View outputs
terraform output

# Format code
terraform fmt -recursive

# Validate
terraform validate

# ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

# Get AWS account ID
aws sts get-caller-identity --query Account --output text

# List ECR images
aws ecr list-images --repository-name load-test

# Delete all ECR images
aws ecr batch-delete-image --repository-name load-test --image-ids "$(aws ecr list-images --repository-name load-test --query 'imageIds[*]' --output json)"
```

---

## Next Steps

After infrastructure is running:
1. Add EC2 instances or ECS for running containers
2. Set up Application Load Balancer
3. Configure CloudWatch monitoring
4. Add auto-scaling
5. Set up CI/CD for deployments

## Support

For issues or questions:
- Check Terraform state: `terraform show`
- View AWS resources: AWS Console
- GitHub Actions logs: Repository Actions tab
