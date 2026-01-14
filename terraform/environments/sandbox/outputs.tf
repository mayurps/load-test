output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# ECR Outputs - Disabled for sandbox (using GitHub Container Registry instead)
# output "ecr_repository_url" {
#   description = "The URL of the ECR repository"
#   value       = module.ecr.repository_url
# }
# 
# output "ecr_repository_name" {
#   description = "The name of the ECR repository"
#   value       = module.ecr.repository_name
# }
# 
# output "ecr_registry_id" {
#   description = "The registry ID"
#   value       = module.ecr.registry_id
# }

# IAM Outputs - Disabled for sandbox with restricted permissions
# Use your existing AWS credentials for GitHub Actions
# 
# output "iam_user_name" {
#   description = "Name of the IAM user for GitHub Actions"
#   value       = module.iam.iam_user_name
# }
# 
# output "iam_access_key_id" {
#   description = "Access key ID for GitHub Actions (add to GitHub secrets)"
#   value       = module.iam.access_key_id
# }
# 
# output "iam_access_key_secret" {
#   description = "Secret access key for GitHub Actions (add to GitHub secrets)"
#   value       = module.iam.access_key_secret
#   sensitive   = true
# }
