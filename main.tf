variable "prefix" {
  default = "s3www-tsl-"
}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "author_mail" {
  default = "foo@example.com"
}
variable "hosted_domain" {
  default = "example.com"
}
variable "custom_domain" {
  default = "www.example.com"
}

locals {
  prefix = var.prefix # just as macro
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      mail         = var.author_mail
      project_name = "s3www-tsl"
      provided_by  = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "cloudfront-acm-certs"
  region = "us-east-1"
  default_tags {
    tags = {
      mail        = var.author_mail
      provided_by = "Terraform"
    }
  }
}
