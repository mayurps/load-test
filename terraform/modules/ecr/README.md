# ECR Module

Modular Terraform configuration for creating an AWS Elastic Container Registry (ECR) repository.

## Features

- **Image scanning** on push for vulnerability detection
- **Lifecycle policies** for automatic image cleanup
- **Encryption** with AES256 or KMS
- **Tag mutability** control (MUTABLE/IMMUTABLE)
- **Cross-account access** (optional)

## Usage

```hcl
module "ecr" {
  source = "../../modules/ecr"

  repository_name       = "load-test"
  image_tag_mutability  = "MUTABLE"
  scan_on_push          = true
  encryption_type       = "AES256"
  image_retention_count = 10
  tags = {
    Project = "load-test"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| repository_name | Name of the ECR repository | string | - | yes |
| image_tag_mutability | Tag mutability (MUTABLE/IMMUTABLE) | string | "MUTABLE" | no |
| scan_on_push | Enable vulnerability scanning | bool | true | no |
| encryption_type | Encryption type (AES256/KMS) | string | "AES256" | no |
| kms_key_arn | KMS key ARN (if using KMS) | string | null | no |
| image_retention_count | Number of images to retain | number | 10 | no |
| enable_cross_account_access | Enable cross-account access | bool | false | no |
| allowed_account_ids | AWS account IDs for cross-account | list(string) | [] | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_url | ECR repository URL (for docker push) |
| repository_arn | ARN of the repository |
| repository_name | Name of the repository |
| registry_id | AWS registry ID |

## Authentication

To push/pull images from ECR:

```bash
# Get login password
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t load-test:latest .

# Tag image
docker tag load-test:latest <repository-url>:latest

# Push image
docker push <repository-url>:latest
```

## Lifecycle Policy

The module automatically creates a lifecycle policy that:
- Keeps the last N images (configurable via `image_retention_count`)
- Applies to all tags
- Helps manage storage costs

## Notes

- Use `MUTABLE` tags for development/sandbox environments
- Use `IMMUTABLE` tags for production to prevent accidental overwrites
- Image scanning helps identify vulnerabilities in base images
- Lifecycle policies run daily to clean up old images
