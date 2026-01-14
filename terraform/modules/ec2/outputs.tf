output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.create_eip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app_server.id
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${var.create_eip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}:8080"
}
