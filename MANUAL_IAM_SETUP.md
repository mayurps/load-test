# Manual IAM Setup for Sandbox Environment

Since the sandbox blocks Terraform from creating IAM users programmatically, you need to create the IAM user manually in the AWS Console.

## Steps to Create IAM User

### 1. Get ECR Repository ARN
First, get the ECR repository ARN that was created by Terraform:

```bash
cd terraform/environments/sandbox
terraform output -raw ecr_repository_arn
```

Copy this ARN - you'll need it for the policy.

### 2. Create IAM User in AWS Console

1. Go to AWS Console → **IAM** → **Users**
2. Click **Create user**
3. User name: `github-actions-ecr-user`
4. Click **Next**
5. Select **Attach policies directly**
6. Click **Create policy** (opens new tab)

### 3. Create ECR Policy

In the policy editor:

**Option A: Visual Editor**
1. Service: **Elastic Container Registry**
2. Actions:
   - Read: `GetAuthorizationToken`, `BatchCheckLayerAvailability`, `GetDownloadUrlForLayer`, `BatchGetImage`, `DescribeRepositories`, `ListImages`, `DescribeImages`
   - Write: `PutImage`, `InitiateLayerUpload`, `UploadLayerPart`, `CompleteLayerUpload`
3. Resources:
   - For authorization token: `All resources` (*)
   - For repository: Add specific ARN from step 1
4. Click **Next**
5. Policy name: `GitHubActionsECRPolicy`
6. Click **Create policy**

**Option B: JSON Editor**
Click **JSON** and paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRAuthToken",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRRepositoryAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages"
      ],
      "Resource": "PASTE_ECR_ARN_HERE"
    }
  ]
}
```

Replace `PASTE_ECR_ARN_HERE` with the ARN from step 1.

### 4. Attach Policy to User

1. Go back to the user creation tab
2. Refresh the policy list
3. Search for `GitHubActionsECRPolicy`
4. Check the box next to it
5. Click **Next**
6. Review and click **Create user**

### 5. Create Access Keys

1. Click on the newly created user `github-actions-ecr-user`
2. Go to **Security credentials** tab
3. Scroll to **Access keys**
4. Click **Create access key**
5. Select **Third-party service**
6. Check the confirmation box
7. Click **Next**
8. Description: `GitHub Actions ECR Push`
9. Click **Create access key**
10. **⚠️ IMPORTANT**: Copy both the **Access key ID** and **Secret access key** immediately - you won't see the secret again!

### 6. Add to GitHub Secrets

Go to your GitHub repository:

1. Settings → Secrets and variables → Actions
2. Click **New repository secret**
3. Add first secret:
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: [paste access key ID from step 5]
4. Click **Add secret**
5. Add second secret:
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: [paste secret access key from step 5]
6. Click **Add secret**

### 7. Verify Secrets

```bash
# If you have GitHub CLI installed
gh secret list

# You should see:
# AWS_ACCESS_KEY_ID        Updated 2026-XX-XX
# AWS_SECRET_ACCESS_KEY    Updated 2026-XX-XX
```

## Quick Reference

**User name**: `github-actions-ecr-user`  
**Policy name**: `GitHubActionsECRPolicy`  
**Required GitHub Secrets**:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Test the Setup

After adding secrets to GitHub:

```bash
# Push code to trigger workflow
git add .
git commit -m "Test ECR push"
git push origin main

# Go to GitHub → Actions tab to see the workflow run
```

## Troubleshooting

### Error: "Not authorized to perform ecr:GetAuthorizationToken"
- Verify the policy JSON includes `ecr:GetAuthorizationToken` with `Resource: "*"`
- Make sure the policy is attached to the user

### Error: "Not authorized to perform ecr:PutImage"
- Check that the ECR repository ARN in the policy matches your repository
- Verify all the actions are included in the policy

### Access key not working
- Make sure you copied the secret access key correctly (it won't be shown again)
- If lost, delete the old access key and create a new one

### GitHub Actions still failing
- Verify secrets are named exactly: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Check there are no extra spaces or newlines in the secret values

## Alternative: Use Existing cloud_user

If creating a new IAM user doesn't work, you can use your existing `cloud_user` credentials:

1. AWS Console → IAM → Users → `cloud_user`
2. Security credentials → Create access key
3. Add to GitHub secrets as above

**Note**: Only do this if the cloud_user has ECR permissions and the explicit deny is removed.
