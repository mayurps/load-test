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
# ECR is blocked in sandbox - using GitHub Container Registry instead
# Your image will be at: ghcr.io/YOUR_USERNAME/load-test:latest
#
# output "ecr_repository_url" {
#   description = "The URL of the ECR repository (use for docker push)"
#   value       = module.ecr.repository_url
# }
#
# output "ecr_repository_name" {
#   description = "The name of the ECR repository"
#   value       = module.ecr.repository_name
# }
#
# output "ecr_repository_arn" {
#   description = "The ARN of the ECR repository"
#   value       = module.ecr.repository_arn
# }
#
# output "ecr_registry_id" {
#   description = "The registry ID (AWS account ID)"
#   value       = module.ecr.registry_id
# }

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

# ==================== EC2 Outputs ====================
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = module.ec2.application_url
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2"
  value       = module.ec2.security_group_id
}

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
    container_registry = "GitHub Container Registry (ghcr.io) - ECR blocked in sandbox"
    image_location = "ghcr.io/YOUR_USERNAME/load-test:latest"
  }
}
