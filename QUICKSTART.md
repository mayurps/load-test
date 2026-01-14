# Quick Start Guide

## Initial Setup (First Time)

```bash
# 1. Deploy infrastructure (VPC + ECR)
cd terraform/environments/sandbox
terraform init
terraform apply
```

## Setup GitHub Secrets (Choose One Method)

### Method A: Use Your Sandbox cloud_user (Easiest) ⭐

See [USE_CLOUD_USER.md](USE_CLOUD_USER.md) for detailed steps.

**Quick version**:
1. AWS Console → IAM → Users → cloud_user → Security credentials
2. Create access key
3. Add to GitHub: Settings → Secrets and variables → Actions
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Method B: Create New IAM User Manually

See [MANUAL_IAM_SETUP.md](MANUAL_IAM_SETUP.md) if you need a dedicated user with limited ECR-only permissions.

## Deploy

```bash
# Push code to trigger build
git add .
git commit -m "Initial setup"
git push origin main

# Watch build in GitHub Actions tab
```

Your Docker image will be automatically pushed to ECR! ✅

## Daily Workflow

```bash
# Make code changes
vim server.js

# Push to trigger build and deployment
git add .
git commit -m "Update server"
git push origin main

# Check GitHub Actions tab for build status
# Image will be automatically pushed to ECR
```

## Recreate Everything (After Destroy)

```bash
cd terraform/environments/sandbox

# Deploy infrastructure
terraform apply

# Update GitHub secrets
cd ../../..
./scripts/setup-github-secrets.sh

# Copy the commands and run them or update manually in GitHub
```

## View Infrastructure

```bash
cd terraform/environments/sandbox

# See all resources
terraform show

# Get specific outputs
terraform output vpc_id
terraform output ecr_repository_url
terraform output iam_access_key_id
```

## Destroy Infrastructure

```bash
cd terraform/environments/sandbox

# Delete all ECR images first
aws ecr batch-delete-image \
  --repository-name load-test \
  --image-ids "$(aws ecr list-images --repository-name load-test --query 'imageIds[*]' --output json)"

# Destroy everything
terraform destroy
```

## Manual Docker Operations

```bash
# Get ECR URL
ECR_URL=$(cd terraform/environments/sandbox && terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ${ECR_URL%/*}

# Build and push
docker build -t load-test:latest .
docker tag load-test:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

## Troubleshooting

### Issue: "Not authorized to perform ecr:GetAuthorizationToken"
**Solution**: Run `terraform apply` to create the IAM user, then update GitHub secrets

### Issue: GitHub Actions failing
**Solution**: Check that GitHub secrets are set correctly:
```bash
# Verify secrets exist
gh secret list

# Update secrets
cd terraform/environments/sandbox
gh secret set AWS_ACCESS_KEY_ID --body "$(terraform output -raw iam_access_key_id)"
gh secret set AWS_SECRET_ACCESS_KEY --body "$(terraform output -raw iam_access_key_secret)"
```

### Issue: Cannot destroy ECR
**Solution**: Delete images first:
```bash
aws ecr batch-delete-image \
  --repository-name load-test \
  --image-ids "$(aws ecr list-images --repository-name load-test --query 'imageIds[*]' --output json)"
```

## Cost Estimate

**Sandbox Environment**: ~$35-40/month
- NAT Gateway: ~$32/month
- Data transfer: ~$0.045/GB
- ECR storage: ~$0.10/GB/month

**To minimize costs**: Run `terraform destroy` when not in use
