variable "user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "github-actions-user"
}

variable "user_path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs the user can access"
  type        = list(string)
  default     = ["*"]
}

variable "create_access_key" {
  description = "Whether to create an access key for the user (will be stored in Terraform state)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
