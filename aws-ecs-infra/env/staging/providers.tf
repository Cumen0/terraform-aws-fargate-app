terraform {
  backend "s3" {
    bucket         = "volodymyr-aws-ecs-infra-tfstate"
    key            = "env/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}