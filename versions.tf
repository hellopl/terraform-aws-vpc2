terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}


provider "aws" {
    region = "eu-north-1"

    default_tags {
        tags = {
            env         = var.env
            terraform   = "true"
        }
    }
}
