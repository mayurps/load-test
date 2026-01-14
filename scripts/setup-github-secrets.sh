#!/bin/bash
set -e

echo "========================================"
echo "Setting up GitHub Secrets"
echo "========================================"
echo ""

# Change to the sandbox directory
cd "$(dirname "$0")/terraform/environments/sandbox"

# Get the outputs
echo "Retrieving AWS credentials from Terraform..."
ACCESS_KEY_ID=$(terraform output -raw iam_access_key_id)
ACCESS_KEY_SECRET=$(terraform output -raw iam_access_key_secret)
ECR_REPO=$(terraform output -raw ecr_repository_name)

echo ""
echo "✅ Credentials retrieved successfully!"
echo ""
echo "========================================"
echo "Add these secrets to GitHub:"
echo "========================================"
echo ""
echo "Go to: Settings > Secrets and variables > Actions > New repository secret"
echo ""
echo "Secret 1:"
echo "  Name:  AWS_ACCESS_KEY_ID"
echo "  Value: $ACCESS_KEY_ID"
echo ""
echo "Secret 2:"
echo "  Name:  AWS_SECRET_ACCESS_KEY"
echo "  Value: $ACCESS_KEY_SECRET"
echo ""
echo "========================================"
echo "Or use GitHub CLI:"
echo "========================================"
echo ""
echo "gh secret set AWS_ACCESS_KEY_ID --body \"$ACCESS_KEY_ID\""
echo "gh secret set AWS_SECRET_ACCESS_KEY --body \"$ACCESS_KEY_SECRET\""
echo ""
echo "========================================"
echo "ECR Repository: $ECR_REPO"
echo "========================================"
echo ""
