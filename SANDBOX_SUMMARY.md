# Sandbox Limitations - Final Summary

## What Works ✅

1. **VPC and Networking**
   - VPC creation
   - Subnets (public/private)
   - Internet Gateway
   - NAT Gateway
   - Route tables
   - Security groups

2. **GitHub Container Registry**
   - Docker image storage
   - Automatic builds via GitHub Actions
   - No AWS credentials needed
   - Free for public repos

3. **Infrastructure as Code**
   - Terraform for VPC
   - Modular design
   - Easy recreation

## What's Blocked ❌

1. **ECR (Elastic Container Registry)**
   - **Why**: Explicit deny on `ecr:GetAuthorizationToken`
   - **Cannot bypass**: This permission is required to authenticate with ECR
   - **Impact**: Cannot push or pull images from ECR
   - **Workaround**: Use GitHub Container Registry (ghcr.io)

2. **IAM User Creation (via Terraform)**
   - **Why**: Sandbox restricts programmatic IAM operations
   - **Can do**: Create users manually in AWS Console
   - **Cannot do**: Create via Terraform/CLI
   - **Impact**: Must manually create any needed IAM users
   - **Workaround**: Use existing cloud_user credentials or create users manually

3. **Other Typical Sandbox Restrictions**
   - Limited regions
   - Service quotas
   - Cost controls
   - Auto-shutdown policies

## Recommended Setup for This Sandbox

### Infrastructure (Terraform)
```
✅ VPC
✅ Subnets
✅ Internet Gateway
✅ NAT Gateway
✅ Route Tables
❌ ECR (disabled)
❌ IAM module (disabled)
```

### Container Registry
```
❌ AWS ECR - blocked
✅ GitHub Container Registry (ghcr.io) - works perfectly
```

### Authentication
```
❌ New IAM users via Terraform - blocked
✅ GITHUB_TOKEN for GHCR - automatic, no config needed
```

## Cost Considerations

**Monthly costs for VPC infrastructure:**
- NAT Gateway: ~$32/month
- Data transfer: ~$0.045/GB
- VPC/Subnets/IGW: Free
- **Total**: ~$35-40/month

**Container storage:**
- GitHub Container Registry: Free (public repos)
- AWS ECR: $0.10/GB (blocked anyway)

## When You Need Full AWS

If you need ECR and full IAM capabilities:

1. **AWS Free Tier Account** (personal)
   - Full permissions
   - ECR works
   - IAM automation works
   - Free tier benefits

2. **AWS Organization Account** (work)
   - Production-ready
   - All services available
   - Proper IAM roles

## Migration Path

When moving from sandbox to production AWS:

1. **Uncomment ECR module** in `main.tf`
2. **Uncomment IAM module** in `main.tf`
3. **Update workflow** to use ECR instead of GHCR
4. **Run terraform apply** - everything will be created
5. **Setup GitHub secrets** from Terraform outputs

All the code is ready - just uncomment the modules!

## Current Working Setup

```yaml
Infrastructure: VPC (Terraform) ✅
Container Registry: GHCR (GitHub) ✅
CI/CD: GitHub Actions ✅
Authentication: GITHUB_TOKEN (automatic) ✅
Cost: ~$35/month (VPC only)
Manual steps: None!
```

## Questions?

- **Why can't I use ECR?** → Sandbox has explicit deny policy blocking `ecr:GetAuthorizationToken`
- **Can I bypass the ECR restriction?** → No, this permission is required and cannot be bypassed
- **Is GHCR good enough?** → Yes! It's production-ready, free, and works great
- **Will this work in production AWS?** → Yes, just uncomment ECR/IAM modules
- **Do I need AWS credentials for GHCR?** → No, uses GitHub's built-in auth

## Bottom Line

✅ **VPC infrastructure**: Fully working via Terraform  
✅ **Container builds**: Fully automated via GitHub Actions  
✅ **Container storage**: GitHub Container Registry (better for this sandbox)  
✅ **Zero manual steps**: Everything automated  
✅ **Cost effective**: Only pay for VPC (~$35/month)  

This is actually a **better** setup for a sandbox environment!
