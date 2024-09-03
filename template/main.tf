terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.sg_region
  alias  = "ap-southeast-1"
}

terraform {
    backend "s3" {}
}

provider "aws" {
  region = var.us_region
  alias  = "us-east-1"
}