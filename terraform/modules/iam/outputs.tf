output "iam_user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.github_actions.name
}

output "iam_user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.github_actions.arn
}

output "access_key_id" {
  description = "Access key ID for the IAM user"
  value       = var.create_access_key ? aws_iam_access_key.github_actions[0].id : null
  sensitive   = false
}

output "access_key_secret" {
  description = "Secret access key for the IAM user"
  value       = var.create_access_key ? aws_iam_access_key.github_actions[0].secret : null
  sensitive   = true
}
