# Sandbox Workaround: Using GitHub Container Registry

## Problem
This AWS sandbox environment has ECR blocked with explicit deny policies:
- Cannot use `ecr:GetAuthorizationToken`
- Cannot create IAM users
- ECR operations are restricted

## Solution: GitHub Container Registry (GHCR)

We've switched to **GitHub Container Registry** (`ghcr.io`) which:
- ✅ **No AWS credentials needed** - uses `GITHUB_TOKEN` automatically
- ✅ **Free for public repos** - unlimited storage and bandwidth
- ✅ **Built into GitHub** - no external setup required
- ✅ **Works immediately** - no configuration needed

## What Changed

### 1. GitHub Actions Workflow
- Changed from ECR to GHCR (`ghcr.io`)
- Uses `GITHUB_TOKEN` (automatic, no secrets needed)
- Automatically tags images with branch name, SHA, and `latest`

### 2. Terraform
- ECR module is commented out in `main.tf`
- Only VPC is created
- IAM module disabled (no permissions to create users)

## Usage

### Push Code (Automatic Build)
```bash
git add .
git commit -m "Your changes"
git push origin main
```

GitHub Actions will automatically:
1. Build the Docker image
2. Push to `ghcr.io/YOUR_USERNAME/load-test`
3. Tag with `latest`, branch name, and commit SHA

### Pull the Image
```bash
# Public repo (no login needed)
docker pull ghcr.io/YOUR_USERNAME/load-test:latest

# Private repo (login required)
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
docker pull ghcr.io/YOUR_USERNAME/load-test:latest
```

### Run the Container
```bash
docker run -d -p 8080:8080 ghcr.io/YOUR_USERNAME/load-test:latest

# Test it
curl http://localhost:8080
```

## Make Package Public (Optional)

If your repo is public but the package is private:

1. Go to your GitHub profile
2. Click **Packages** tab
3. Click on **load-test** package
4. Click **Package settings** (bottom right)
5. Scroll to **Danger Zone**
6. Click **Change visibility** → Make public

## Infrastructure Deployment

```bash
cd terraform/environments/sandbox

# This now only creates VPC (ECR disabled)
terraform apply

# Expected resources:
# - VPC with subnets ✅
# - Internet Gateway ✅
# - NAT Gateway ✅
# - Route tables ✅
```

## For Production (Non-Sandbox AWS)

In a real AWS account with full permissions:

1. Uncomment ECR module in `main.tf`
2. Uncomment IAM module in `main.tf`
3. Update workflow to use ECR (see `.github/workflows/push-to-ecr.yml.backup`)
4. Run `terraform apply`

## Advantages of GHCR

1. **Simpler**: No AWS credentials to manage
2. **Free**: No ECR storage costs
3. **Integrated**: Works seamlessly with GitHub Actions
4. **Secure**: Uses GitHub's built-in authentication
5. **Fast**: GitHub's CDN for image pulls

## Viewing Your Images

- Go to: `https://github.com/YOUR_USERNAME?tab=packages`
- Or check your repo → Packages section

## Next Steps

With GHCR working, you can now deploy the container to:
- AWS EC2 (pull from GHCR)
- AWS ECS (pull from GHCR)
- Any Kubernetes cluster
- Your local machine
- Any server with Docker

No AWS ECR needed! 🎉
