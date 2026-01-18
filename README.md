# GitHub to AWS OIDC Integration

This repository contains Infrastructure as Code (IaC) to set up OpenID Connect (OIDC) identity provider for seamless GitHub Actions to AWS authentication.

## Overview

Using OIDC eliminates the need for long-lived AWS access keys. GitHub Actions can authenticate directly to AWS using temporary credentials via OIDC.

## Architecture

- **OIDC Provider**: GitHub (https://token.actions.githubusercontent.com)
- **IAM Role**: AWS role that GitHub can assume
- **Trust Policy**: Allows specific GitHub repos/workflows to assume the role

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository
- Terraform installed locally (v1.0+)
- AWS CLI configured

## Directory Structure

```
.
├── terraform/
│   ├── main.tf              # Main OIDC configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── terraform.tfvars     # Variable values (update with your values)
├── .github/
│   └── workflows/
│       └── deploy.yml       # Example workflow using OIDC
├── README.md                # This file
└── .gitignore               # Git ignore rules
```

## Setup Instructions

### 1. Update Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
github_org           = "your-github-org"
github_repo_name     = "your-repo-name"
aws_account_id       = "your-aws-account-id"
iam_role_name        = "github-oidc-role"
github_workflows     = ["deploy.yml"]  # List of workflows that can use this role
```

### 2. Deploy with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Use in GitHub Actions

In your GitHub workflow (`.github/workflows/deploy.yml`):

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-oidc-role
          aws-region: us-east-1
      
      - name: Run AWS CLI command
        run: aws sts get-caller-identity
```

## Security Best Practices

1. **Limit by repository**: Configure trust policy to specific repos only
2. **Limit by branch**: Restrict to specific branches (e.g., main)
3. **Limit by environment**: Use GitHub environments for additional control
4. **Minimal permissions**: Grant only required AWS permissions to the role
5. **No long-lived credentials**: Never store AWS keys in GitHub secrets

## Troubleshooting

### OIDC Token validation fails
- Ensure GitHub repo name matches exactly in trust policy
- Verify GitHub organization name
- Check that the OIDC provider exists in IAM

### Access Denied errors
- Check IAM policy attached to the role
- Verify the role has the necessary permissions
- Check role trust relationship

## Resources

- [AWS OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

MIT
