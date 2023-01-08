provider "aws" {
  region  = var.aws_region
  profile = "jenkins"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-mirom-${var.project_name}-${var.env}"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
