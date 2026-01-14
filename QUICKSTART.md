# Quick Start Guide - Deploy to EC2 from GHCR

## Overview

This setup deploys your Docker container from GitHub Container Registry to AWS EC2:
- ✅ VPC infrastructure via Terraform
- ✅ Container storage in GHCR (free, no AWS needed)
- ✅ Automatic container deployment to EC2
- ✅ No ECR needed (sandbox blocks it anyway)

## Setup Steps

### 1. Update GitHub Username

Edit `terraform/environments/sandbox/terraform.tfvars`:

```hcl
github_username = "your-github-username"  # IMPORTANT: Replace this!
```

### 2. Deploy Infrastructure

```bash
cd terraform/environments/sandbox
terraform init
terraform apply
```

This creates:
- VPC and networking
- EC2 instance
- Automatically pulls your container from GHCR
- Starts your app on port 8080

### 3. Get Your Application URL

```bash
terraform output application_url
```

Example output: `http://54.123.45.67:8080`

### 4. Test It

```bash
# Copy the URL from step 3 and test
curl http://YOUR_EC2_IP:8080
```

You should see your app responding! 🎉

## How It Works

1. **Push code** → GitHub Actions builds Docker image
2. **Image stored** → GitHub Container Registry (ghcr.io)
3. **EC2 pulls** → Container from GHCR on boot
4. **App runs** → Accessible on port 8080

## Workflow

### Make Changes

```bash
# Edit your code
vim server.js

# Commit and push
git add .
git commit -m "Update server"
git push origin main
```

### GitHub Actions automatically:
1. Builds new Docker image
2. Pushes to GHCR with `:latest` tag

### Update EC2 (Manual for now)

```bash
# Get EC2 IP
EC2_IP=$(cd terraform/environments/sandbox && terraform output -raw ec2_public_ip)

# SSH to EC2 (if you have key)
ssh ec2-user@$EC2_IP

# Run update script
sudo /usr/local/bin/update-app.sh
```

## Costs

- **t3.micro EC2**: ~$8/month (free tier: 750 hours/month)
- **NAT Gateway**: ~$32/month
- **Total**: ~$40/month (~$8/month with free tier)

## What's Created

- ✅ VPC (10.0.0.0/24)
- ✅ Public/private subnets
- ✅ Internet Gateway
- ✅ NAT Gateway
- ✅ EC2 instance (t3.micro)
- ✅ Elastic IP (stable address)
- ✅ Security group (ports 8080, 22)

## Cleanup

```bash
cd terraform/environments/sandbox
terraform destroy
```

## See Also

- [EC2_DEPLOYMENT.md](EC2_DEPLOYMENT.md) - Complete EC2 deployment guide
- [SANDBOX_SUMMARY.md](SANDBOX_SUMMARY.md) - Sandbox limitations explained
- [GHCR_SETUP.md](GHCR_SETUP.md) - GitHub Container Registry details

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
