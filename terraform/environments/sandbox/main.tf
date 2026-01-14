module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
  environment           = var.environment
  tags                  = var.common_tags
}

# ECR module - Re-enable if you have ECR permissions
module "ecr" {
  source = "../../modules/ecr"

  repository_name       = var.ecr_repository_name
  image_tag_mutability  = var.ecr_image_tag_mutability
  scan_on_push          = var.ecr_scan_on_push
  encryption_type       = var.ecr_encryption_type
  image_retention_count = var.ecr_image_retention_count
  tags                  = var.common_tags
}

# IAM module disabled - sandbox blocks programmatic IAM creation
# Create IAM user manually in AWS Console instead (see MANUAL_IAM_SETUP.md)
# 
# module "iam" {
#   source = "../../modules/iam"
# 
#   user_name           = var.iam_user_name
#   ecr_repository_arns = [module.ecr.repository_arn]
#   create_access_key   = var.iam_create_access_key
#   tags                = var.common_tags
# }
