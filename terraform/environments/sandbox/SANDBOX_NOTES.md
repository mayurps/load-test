# Sandbox Environment - IAM Restrictions

## Issue
AWS sandbox environments typically restrict IAM user creation for security reasons.

## Solution
Use your existing AWS credentials (cloud_user) for GitHub Actions instead of creating a new IAM user.

## GitHub Secrets Setup

Add these secrets to your GitHub repository:

1. **AWS_ACCESS_KEY_ID**: Your existing AWS access key
2. **AWS_SECRET_ACCESS_KEY**: Your existing AWS secret key

### Get Your Credentials

If you don't have access keys yet:

```bash
# Check your current identity
aws sts get-caller-identity

# Get your access key from AWS console:
# AWS Console → IAM → Users → cloud_user → Security credentials → Create access key
```

Or if you already configured AWS CLI:

```bash
# View your credentials
cat ~/.aws/credentials

# The values under [default] are:
# aws_access_key_id = YOUR_ACCESS_KEY
# aws_secret_access_key = YOUR_SECRET_KEY
```

### Add to GitHub

**Option 1: GitHub UI**
1. Go to your repo: Settings → Secrets and variables → Actions
2. Add `AWS_ACCESS_KEY_ID` with your access key
3. Add `AWS_SECRET_ACCESS_KEY` with your secret key

**Option 2: GitHub CLI**
```bash
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_KEY"
```

## Applying Terraform

```bash
# Cancel the stuck apply (Ctrl+C)
# Then apply without IAM module
terraform apply
```

This will create:
- VPC and networking ✅
- ECR repository ✅
- ~~IAM user~~ (skipped due to permissions)

## For Production

In a production AWS account with full IAM permissions, uncomment the IAM module in `main.tf` to have Terraform manage dedicated CI/CD credentials.
