variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-east-1"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  validation {
    condition     = length(var.github_org) > 0
    error_message = "GitHub organization must not be empty."
  }
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  validation {
    condition     = length(var.github_repo_name) > 0
    error_message = "GitHub repository name must not be empty."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  validation {
    condition     = length(var.aws_account_id) == 12 && can(tonumber(var.aws_account_id))
    error_message = "AWS Account ID must be a 12-digit number."
  }
}

variable "iam_role_name" {
  description = "Name of the IAM role for GitHub OIDC"
  type        = string
  default     = "github-oidc-role"
  validation {
    condition     = length(var.iam_role_name) > 0
    error_message = "IAM role name must not be empty."
  }
}

variable "github_workflows" {
  description = "List of GitHub workflows that can use this role"
  type        = list(string)
  default     = ["deploy.yml"]
}
