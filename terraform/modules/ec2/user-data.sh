#!/bin/bash
set -e

# Update system
dnf update -y

# Install Docker
dnf install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Pull and run container from GitHub Container Registry
docker pull ghcr.io/${github_user}/${github_repo}:latest

# Run the container
docker run -d \
  --name load-test-app \
  --restart unless-stopped \
  -p ${container_port}:${container_port} \
  ghcr.io/${github_user}/${github_repo}:latest

# Create update script for future deployments
cat > /usr/local/bin/update-app.sh << 'EOF'
#!/bin/bash
echo "Pulling latest image..."
docker pull ghcr.io/${github_user}/${github_repo}:latest

echo "Stopping current container..."
docker stop load-test-app || true
docker rm load-test-app || true

echo "Starting new container..."
docker run -d \
  --name load-test-app \
  --restart unless-stopped \
  -p ${container_port}:${container_port} \
  ghcr.io/${github_user}/${github_repo}:latest

echo "Cleaning up old images..."
docker image prune -af

echo "✅ Application updated successfully!"
EOF

chmod +x /usr/local/bin/update-app.sh

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
