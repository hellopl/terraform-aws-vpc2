# This block specifies the required providers, in this case only AWS
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

# This block defines the AWS provider configuration
provider "aws" {
    region = "eu-north-1"

    default_tags {
        tags = {
            env         = var.env
            terraform   = "true"
        }
    }
}
