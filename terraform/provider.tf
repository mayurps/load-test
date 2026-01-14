provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "load-test"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
