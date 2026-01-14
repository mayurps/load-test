#!/bin/bash
# Script to display all Terraform outputs in a readable format

set -e

cd "$(dirname "$0")/../terraform/environments/sandbox"

echo "========================================="
echo "TERRAFORM INFRASTRUCTURE OUTPUTS"
echo "========================================="
echo ""

echo "🌐 VPC Information"
echo "-------------------"
echo "VPC ID:            $(terraform output -raw vpc_id 2>/dev/null || echo 'N/A')"
echo "VPC CIDR:          $(terraform output -raw vpc_cidr_block 2>/dev/null || echo 'N/A')"
echo "Region:            us-east-1"
echo "Environment:       sandbox"
echo ""

echo "🔌 Networking"
echo "-------------------"
echo "Internet Gateway:  $(terraform output -raw internet_gateway_id 2>/dev/null || echo 'N/A')"
echo "NAT Gateway IPs:   $(terraform output -json nat_gateway_public_ips 2>/dev/null | jq -r '.[]' | tr '\n' ', ' | sed 's/,$//' || echo 'N/A')"
echo ""
echo "Public Subnets:    $(terraform output -json public_subnet_ids 2>/dev/null | jq -r '.[]' | tr '\n' ', ' | sed 's/,$//' || echo 'N/A')"
echo "Private Subnets:   $(terraform output -json private_subnet_ids 2>/dev/null | jq -r '.[]' | tr '\n' ', ' | sed 's/,$//' || echo 'N/A')"
echo ""

echo "📦 ECR Repository"
echo "-------------------"
echo "Repository URL:    $(terraform output -raw ecr_repository_url 2>/dev/null || echo 'N/A')"
echo "Repository Name:   $(terraform output -raw ecr_repository_name 2>/dev/null || echo 'N/A')"
echo "Registry ID:       $(terraform output -raw ecr_registry_id 2>/dev/null || echo 'N/A')"
echo ""

echo "👤 IAM User (GitHub Actions)"
echo "-------------------"
echo "User Name:         $(terraform output -raw iam_user_name 2>/dev/null || echo 'N/A')"
echo "User ARN:          $(terraform output -raw iam_user_arn 2>/dev/null || echo 'N/A')"
echo "Access Key ID:     $(terraform output -raw iam_access_key_id 2>/dev/null || echo 'N/A')"
echo ""

echo "🔐 GitHub Secrets Required"
echo "-------------------"
if terraform output -raw iam_access_key_id >/dev/null 2>&1; then
    ACCESS_KEY_ID=$(terraform output -raw iam_access_key_id)
    ACCESS_KEY_SECRET=$(terraform output -raw iam_access_key_secret)
    
    echo "Add these to GitHub → Settings → Secrets and variables → Actions:"
    echo ""
    echo "  AWS_ACCESS_KEY_ID = $ACCESS_KEY_ID"
    echo "  AWS_SECRET_ACCESS_KEY = [HIDDEN - run: terraform output -raw iam_access_key_secret]"
    echo ""
    echo "Quick setup with GitHub CLI:"
    echo "  gh secret set AWS_ACCESS_KEY_ID --body \"$ACCESS_KEY_ID\""
    echo "  gh secret set AWS_SECRET_ACCESS_KEY --body \"$ACCESS_KEY_SECRET\""
else
    echo "IAM outputs not available. Run 'terraform apply' first."
fi
echo ""

echo "📋 Complete Summary"
echo "-------------------"
terraform output -json infrastructure_summary 2>/dev/null | jq '.' || echo "Summary not available"
echo ""

echo "========================================="
echo "To see all raw outputs: terraform output"
echo "To see specific output: terraform output -raw <output_name>"
echo "========================================="
