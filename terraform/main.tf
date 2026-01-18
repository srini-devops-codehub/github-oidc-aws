terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# GitHub OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name        = "github-oidc-provider"
    Environment = "production"
  }
}

# IAM Role that GitHub can assume
resource "aws_iam_role" "github_oidc_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name        = var.iam_role_name
    Environment = "production"
  }
}

# Trust policy - allows GitHub to assume the role
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_org}/*"
      ]
    }
  }
}

# Attach permissions policy to the role
# This is a basic S3 and Lambda deployment policy - modify as needed
resource "aws_iam_role_policy" "github_deployment_policy" {
  name   = "${var.iam_role_name}-policy"
  role   = aws_iam_role.github_oidc_role.id
  policy = data.aws_iam_policy_document.github_deployment_policy.json
}

data "aws_iam_policy_document" "github_deployment_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:DeleteFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Output the role ARN for use in GitHub Actions
output "github_role_arn" {
  description = "ARN of the IAM role for GitHub OIDC"
  value       = aws_iam_role.github_oidc_role.arn
}
