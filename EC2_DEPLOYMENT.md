# EC2 Deployment from GitHub Container Registry

Complete setup for deploying your Docker container from GHCR to EC2.

## Prerequisites

1. GitHub Container Registry image (built by GitHub Actions)
2. AWS VPC infrastructure (created by Terraform)
3. Your GitHub username

## Setup Steps

### 1. Update Terraform Variables

Edit `terraform/environments/sandbox/terraform.tfvars`:

```hcl
github_username = "your-actual-github-username"  # Replace this!
```

### 2. Apply Terraform

```bash
cd terraform/environments/sandbox
terraform init
terraform apply
```

This creates:
- ✅ VPC and networking
- ✅ EC2 instance (t3.micro)
- ✅ Security group (ports 8080, 22)
- ✅ Elastic IP (stable address)
- ✅ Automatically pulls and runs your container from GHCR

### 3. Get Application URL

```bash
terraform output application_url
```

Copy this URL and open in browser - your app is running!

Example: `http://54.123.45.67:8080`

### 4. Test It

```bash
# Get the URL
APP_URL=$(terraform output -raw application_url)

# Test the endpoint
curl $APP_URL

# You should see a 2KB response
```

## How It Works

### Initial Deployment

1. Terraform creates EC2 instance
2. User data script runs on boot:
   - Installs Docker
   - Pulls image from `ghcr.io/YOUR_USERNAME/load-test:latest`
   - Starts container on port 8080
3. Application is accessible via public IP

### Updates (After Code Changes)

When you push code to GitHub:

1. GitHub Actions builds new image
2. Pushes to GHCR with `:latest` tag
3. **Manual update on EC2**:

```bash
# SSH to EC2 (if you have SSH key)
ssh ec2-user@EC2_PUBLIC_IP

# Run update script
sudo /usr/local/bin/update-app.sh
```

Or create deployment script (see below).

## Outputs

After `terraform apply`:

```bash
# EC2 instance ID
terraform output ec2_instance_id

# Public IP address
terraform output ec2_public_ip

# Application URL
terraform output application_url

# Security group
terraform output ec2_security_group_id

# All infrastructure
terraform output infrastructure_summary
```

## Architecture

```
┌─────────────────────────────────────────┐
│           GitHub Actions                 │
│                                          │
│  1. Build Docker image                  │
│  2. Push to ghcr.io                     │
└─────────────────┬───────────────────────┘
                  │
                  │ docker pull
                  │
┌─────────────────▼───────────────────────┐
│         AWS EC2 Instance                 │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │   Docker Container                 │ │
│  │   Port 8080                        │ │
│  │   ghcr.io/user/load-test:latest   │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Public IP: X.X.X.X (Elastic IP)       │
└──────────────────────────────────────────┘
                  │
                  │ HTTP
                  │
            ┌─────▼─────┐
            │  Internet  │
            └────────────┘
```

## Costs

**Monthly estimate:**
- t3.micro EC2: ~$8/month (free tier eligible)
- Elastic IP: Free (when attached)
- NAT Gateway: ~$32/month
- **Total: ~$40/month**

**Free tier:** First 12 months on new AWS accounts get 750 hours/month of t3.micro free

## Security Groups

**Inbound rules:**
- Port 8080: Allow from 0.0.0.0/0 (HTTP traffic)
- Port 22: Allow from 0.0.0.0/0 (SSH - restrict this in production!)

**Outbound rules:**
- All traffic allowed (for pulling Docker images)

## SSH Access (Optional)

To enable SSH access:

1. Create EC2 key pair in AWS Console
2. Update `terraform.tfvars`:
   ```hcl
   ec2_ssh_key_name = "your-key-pair-name"
   ```
3. Apply Terraform
4. SSH to instance:
   ```bash
   ssh -i your-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
   ```

## Troubleshooting

### Application not accessible

```bash
# Check EC2 status
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Check security group
aws ec2 describe-security-groups --group-ids $(terraform output -raw ec2_security_group_id)
```

### Container not running (with SSH access)

```bash
# SSH to instance
ssh ec2-user@EC2_IP

# Check Docker containers
docker ps

# Check Docker logs
docker logs load-test-app

# Check user data logs
sudo cat /var/log/user-data.log
```

### Can't pull from GHCR

Make sure your GHCR package is public:
1. GitHub profile → Packages
2. Click on load-test package
3. Package settings → Change visibility → Public

## Manual Deployment Updates

Create a GitHub Actions workflow to deploy after image build:

```yaml
# Add to .github/workflows/push-to-ecr.yml after build step

- name: Deploy to EC2
  run: |
    # This would SSH to EC2 and run update script
    # Requires: AWS_EC2_IP and SSH_PRIVATE_KEY secrets
    echo "Deployment would trigger here"
```

Or use AWS SSM for deployment without SSH.

## Cleanup

```bash
cd terraform/environments/sandbox
terraform destroy
```

This removes:
- EC2 instance
- Elastic IP
- Security group
- VPC and networking

## Next Steps

- [ ] Set up automated deployments
- [ ] Add load balancer
- [ ] Enable auto-scaling
- [ ] Add CloudWatch monitoring
- [ ] Configure SSL/TLS
- [ ] Restrict SSH access
