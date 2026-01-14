# IAM User for GitHub Actions
resource "aws_iam_user" "github_actions" {
  name = var.user_name
  path = var.user_path

  tags = merge(
    var.tags,
    {
      Name        = var.user_name
      Purpose     = "GitHub Actions CI/CD"
      ManagedBy   = "Terraform"
    }
  )
}

# IAM Policy for ECR Access
resource "aws_iam_policy" "ecr_push_pull" {
  name        = "${var.user_name}-ecr-policy"
  description = "Policy for GitHub Actions to push/pull images to/from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })

  tags = var.tags
}

# Attach Policy to User
resource "aws_iam_user_policy_attachment" "ecr_push_pull" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_push_pull.arn
}

# Create Access Key (stored in Terraform state - use with caution)
resource "aws_iam_access_key" "github_actions" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.github_actions.name
}
