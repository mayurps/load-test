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

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

# ==================== ECR Outputs ====================
output "ecr_repository_url" {
  description = "The URL of the ECR repository (use for docker push)"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_registry_id" {
  description = "The registry ID (AWS account ID)"
  value       = module.ecr.registry_id
}

# ==================== IAM Outputs ====================
# IAM user must be created manually in sandbox
# See MANUAL_IAM_SETUP.md for instructions
# 
# output "iam_user_name" {
#   description = "Name of the IAM user for GitHub Actions"
#   value       = module.iam.iam_user_name
# }
# 
# output "iam_user_arn" {
#   description = "ARN of the IAM user"
#   value       = module.iam.iam_user_arn
# }
# 
# output "iam_access_key_id" {
#   description = "Access key ID for GitHub Actions (add to GitHub secrets)"
#   value       = module.iam.access_key_id
# }
# 
# output "iam_access_key_secret" {
#   description = "Secret access key for GitHub Actions (add to GitHub secrets - ONLY SHOWN ONCE)"
#   value       = module.iam.access_key_secret
#   sensitive   = true
# }

# ==================== Summary Output ====================
output "infrastructure_summary" {
  description = "Summary of all created infrastructure"
  value = {
    vpc = {
      id         = module.vpc.vpc_id
      cidr       = module.vpc.vpc_cidr_block
      region     = var.aws_region
      environment = var.environment
    }
    networking = {
      public_subnets  = module.vpc.public_subnet_ids
      private_subnets = module.vpc.private_subnet_ids
      nat_gateways    = module.vpc.nat_gateway_public_ips
      internet_gateway = module.vpc.internet_gateway_id
    }
    ecr = {
    note = "IAM user must be created manually - see MANUAL_IAM_SETUP.md"am = {
      user_name = module.iam.iam_user_name
      user_arn  = module.iam.iam_user_arn
    }
  }
}
