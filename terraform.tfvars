# This file contains the variables required for Terraform to create the VPC and subnets.
# The VPC CIDR block determines the range of IP addresses that can be used for the VPC
vpc_cidr = "10.40.0.0/16"

# The environment variable is used to differentiate between different environments (dev, prod, staging).
env = "dev"

# The public_subnet_cidrs variable contains a list of CIDR blocks for the public subnets.
public_subnet_cidrs =  [
        "10.40.11.0/24",
        "10.40.12.0/24",
        "10.40.13.0/24"        
    ]

#The private_subnet_cidrs variable contains a list of CIDR blocks for the private subnets.
private_subnet_cidrs = [
        "10.40.21.0/24",
        "10.40.22.0/24",
        "10.40.23.0/24"         
    ]

# Please do not modify this file unless you know what you are doing!