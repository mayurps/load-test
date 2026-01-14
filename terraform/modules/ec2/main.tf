# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2
resource "aws_security_group" "app_server" {
  name        = "${var.environment}-app-server-sg"
  description = "Security group for application server"
  vpc_id      = var.vpc_id

  # HTTP access for the application
  ingress {
    description = "HTTP from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access (restrict this in production)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-app-server-sg"
    }
  )
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_server.id]
  key_name               = var.key_name

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    github_user       = var.github_user
    github_repo       = var.github_repo
    container_port    = var.container_port
  }))

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-app-server"
    }
  )
}

# Elastic IP for stable address
resource "aws_eip" "app_server" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-app-server-eip"
    }
  )
}
