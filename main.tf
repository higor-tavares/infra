terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  required_version = ">= 1.2.0"
}

locals {
  region = "us-west-1"
  account = "418272752891"
}

provider "aws" {
  region = local.region
}