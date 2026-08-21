variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Short name used to prefix resources"
  type        = string
  default     = "oidc-demo"
}

variable "github_org" {
  description = "GitHub org or username that owns the repo"
  type        = string
  default     = "jamilkhan-me"
}

variable "github_repo" {
  description = "GitHub repository name (without org prefix)"
  type        = string
  default     = "AWS-Terraform-GithubAction-OIDC-project"
}

variable "github_branch" {
  description = "Branch allowed to assume the deploy role"
  type        = string
  default     = "main"
}
