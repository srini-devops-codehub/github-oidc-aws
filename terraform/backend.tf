terraform {
  backend "s3" {
    bucket         = "terraform-state-494662239150"
    key            = "github-oidc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
