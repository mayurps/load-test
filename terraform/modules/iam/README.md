# IAM Module

Terraform module for creating IAM users and policies for GitHub Actions CI/CD.

## Features

- **IAM User** for GitHub Actions
- **ECR Policies** for push/pull access
- **Access Key** creation (optional)
- **Least Privilege** - only ECR permissions

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  user_name            = "github-actions-ecr"
  ecr_repository_arns  = [module.ecr.repository_arn]
  create_access_key    = true
  tags                 = var.common_tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| user_name | IAM user name | string | "github-actions-user" | no |
| user_path | IAM user path | string | "/" | no |
| ecr_repository_arns | ECR repository ARNs | list(string) | ["*"] | no |
| create_access_key | Create access key | bool | true | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| iam_user_name | IAM user name | no |
| iam_user_arn | IAM user ARN | no |
| access_key_id | Access key ID | no |
| access_key_secret | Secret access key | yes |

## Security Notes

⚠️ **Access keys are stored in Terraform state file**

For production, consider:
- Using GitHub OIDC instead of access keys
- Storing access keys in AWS Secrets Manager
- Setting `create_access_key = false` and creating keys manually

## Retrieving Credentials

After applying Terraform:

```bash
# Get access key ID (not sensitive)
terraform output iam_access_key_id

# Get secret access key (sensitive - only shown once)
terraform output -raw iam_access_key_secret
```

## Permissions Granted

The IAM user has permission to:
- Get ECR authorization token
- Push images to ECR
- Pull images from ECR
- List and describe ECR repositories
- List and describe images

## Alternative: GitHub OIDC (Recommended for Production)

For production environments, use GitHub's OIDC provider instead of access keys:

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:your-org/your-repo:*"
        }
      }
    }]
  })
}
```

This eliminates the need for long-lived access keys.
