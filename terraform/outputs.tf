output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "oidc_role_arn" {
  description = "ARN of the IAM role that GitHub can assume"
  value       = aws_iam_role.github_oidc_role.arn
}

output "oidc_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.github_oidc_role.name
}

output "github_actions_configuration" {
  description = "Configuration values to use in GitHub Actions"
  value = {
    role_to_assume = aws_iam_role.github_oidc_role.arn
    aws_region     = var.aws_region
    github_org     = var.github_org
    github_repo    = var.github_repo_name
  }
}
