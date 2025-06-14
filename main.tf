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

resource "aws_apprunner_observability_configuration" "xray" {
  observability_configuration_name = "${local.name}-xray"
  trace_configuration {
    vendor = "AWSXRAY"
  }
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

  health_check_configuration {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 1
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
  }

  observability_configuration {
    observability_enabled           = true
    observability_configuration_arn = aws_apprunner_observability_configuration.xray.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.default.arn
}

resource "aws_apprunner_auto_scaling_configuration_version" "default" {
  auto_scaling_configuration_name = "${local.name}-autoscaling"
  max_size                        = 3
  min_size                        = 1
  max_concurrency                 = 100
}
