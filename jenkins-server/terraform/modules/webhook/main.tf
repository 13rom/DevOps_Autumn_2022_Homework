# Add GitHub repository webhook for Jenkins pipeline

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_repo_token
}


variable "github_repo_name" {}
variable "github_webhook_url" {}
variable "github_owner" {}
variable "github_repo_token" {}


resource "github_repository_webhook" "repo" {
  repository = var.github_repo_name

  configuration {
    url          = var.github_webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
