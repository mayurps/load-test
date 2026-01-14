# Using Your Sandbox cloud_user for GitHub Actions

The simplest approach for sandbox environments is to use your existing `cloud_user` credentials.

## Steps

### 1. Get Your AWS Account ID

```bash
cd terraform/environments/sandbox
terraform output -raw ecr_registry_id
```

This is your AWS account ID (also the ECR registry ID).

### 2. Get Your cloud_user Access Keys

You need to create access keys for your existing `cloud_user`:

#### Option A: AWS Console (Easiest)

1. Go to AWS Console → **IAM** → **Users**
2. Click on **cloud_user** (your sandbox user)
3. Click **Security credentials** tab
4. Scroll down to **Access keys**
5. Click **Create access key**
6. Select use case: **Command Line Interface (CLI)**
7. Check the confirmation box
8. Click **Next**
9. Description (optional): `GitHub Actions`
10. Click **Create access key**
11. **⚠️ IMPORTANT**: Copy both the **Access key ID** and **Secret access key** immediately!

#### Option B: Check Existing Credentials

If you already configured AWS on your machine, check:

```bash
cat ~/.aws/credentials
```

You'll see:
```
[default]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

Use these values for GitHub secrets.

### 3. Add to GitHub Secrets

Go to your GitHub repository:

1. **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

Add these two secrets:

| Secret Name | Value | Where to Get |
|------------|-------|--------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | From step 2 |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtn...` | From step 2 |

#### Using GitHub CLI (Faster)

```bash
# If using existing credentials
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_ACCESS_KEY"
```

### 4. Update Workflow (if needed)

Your workflow is already configured correctly in `.github/workflows/push-to-ecr.yml`.

It will:
1. Use the secrets to authenticate with AWS
2. Login to ECR
3. Build and push your Docker image

### 5. Test It

```bash
git add .
git commit -m "Use cloud_user credentials for ECR"
git push origin main
```

Go to GitHub → **Actions** tab to watch the build.

### 6. Verify in AWS

After the workflow completes:

1. AWS Console → **ECR** → **Repositories**
2. Click on **load-test** repository
3. You should see your Docker image with tags like `latest` and the commit SHA

## Verify Your Secrets

```bash
# List secrets in GitHub repo
gh secret list

# Expected output:
# AWS_ACCESS_KEY_ID        Updated 2026-01-15
# AWS_SECRET_ACCESS_KEY    Updated 2026-01-15
```

## Troubleshooting

### Error: "Not authorized to perform ecr:GetAuthorizationToken"

Your cloud_user may have restrictions. Check your permissions:

1. AWS Console → IAM → Users → cloud_user
2. Click **Permissions** tab
3. Check if there are any **Deny** policies blocking ECR

**If blocked**: You'll need to create a separate IAM user with ECR permissions (see [MANUAL_IAM_SETUP.md](MANUAL_IAM_SETUP.md))

### Error: Access key is invalid

- Make sure you copied the entire key without extra spaces
- The secret access key is case-sensitive
- If you lost the secret key, delete it and create a new access key

### Workflow runs but no image in ECR

- Check the GitHub Actions logs for errors
- Verify the ECR repository exists: `terraform output ecr_repository_url`
- Check that both secrets are set correctly in GitHub

## Security Note

⚠️ These credentials have full access to your sandbox account. Best practices:

1. **Only use in GitHub Actions** - Don't share them
2. **Rotate regularly** - Create new keys every 90 days
3. **Delete when done** - Remove access keys when you're done with the sandbox
4. **Use in private repos only** - Never commit credentials to code

## Clean Up

When you're done with the sandbox:

### Delete Access Keys
1. AWS Console → IAM → Users → cloud_user
2. Security credentials tab
3. Find the access key
4. Click **Actions** → **Delete**

### Remove GitHub Secrets
```bash
gh secret remove AWS_ACCESS_KEY_ID
gh secret remove AWS_SECRET_ACCESS_KEY
```

Or in GitHub UI: Settings → Secrets and variables → Actions → Delete each secret

## Next Steps

With credentials configured:
- ✅ GitHub Actions will automatically build and push images to ECR
- ✅ No manual intervention needed
- ✅ Every push to `main` branch triggers a build

Pull your image from ECR:
```bash
# Get the repository URL
ECR_URL=$(cd terraform/environments/sandbox && terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_URL%/*}

# Pull the image
docker pull $ECR_URL:latest

# Run it
docker run -d -p 8080:8080 $ECR_URL:latest
```
