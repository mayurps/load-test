variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name (optional - for SSH access)"
  type        = string
  default     = null
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "github_user" {
  description = "GitHub username for pulling images from GHCR"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 8080
}

variable "create_eip" {
  description = "Whether to create an Elastic IP"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
