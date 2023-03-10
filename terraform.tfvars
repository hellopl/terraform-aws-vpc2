# The range of IP addresses for VPC.
vpc_cidr = "10.40.0.0/16"

# (dev, prod, staging, test)
env = "dev"

# The public_subnet_cidrs starts from 11.
public_subnet_cidrs =  [
        "10.40.11.0/24",
        "10.40.12.0/24",
        "10.40.13.0/24"        
    ]

# The private_subnet_cidrs starts from 21.
private_subnet_cidrs = [
        "10.40.21.0/24",
        "10.40.22.0/24",
        "10.40.23.0/24"         
    ]
