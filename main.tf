provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name = "hello-apprunner"
    }
  }
}

data "aws_default_tags" "default" {}

locals {
    name = data.aws_default_tags.default.tags.Name
}

resource "aws_apprunner_service" "default" {
  service_name = local.name

  source_configuration {
    auto_deployments_enabled = false
    image_repository {
      image_identifier      = "public.ecr.aws/nginx/nginx:latest"
      image_repository_type = "ECR_PUBLIC"
      image_configuration {
        port = "80"
      }
    }
  }

  instance_configuration {
    cpu    = "256"
    memory = "512"
  }
}
