locals {
  alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]     # Define a list of alphabet letters, to be used later for naming subnets. Instead of numbering in digits, it will be in letters A, B, C...
}

data "aws_availability_zones" "zone" {}

resource "aws_vpc" "this" {
    cidr_block                          = var.vpc_cidr
    assign_generated_ipv6_cidr_block    = true     # Automatically generate an IPv6 CIDR block for the VPC

    tags = {
        Name = "${var.env} VPC2"                   # the scheme of VPC2 see in the repo's README  
    }
}

resource "aws_egress_only_internet_gateway" "this" {    # Сreate an egress-only internet gateway for private subnets (IPv6 only) 
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.env} EIGW"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id  = aws_vpc.this.id

    tags = {
        Name = "${var.env} IGW"
    }
}

#----------------------Public subnets with route table-----------------------------

resource "aws_subnet" "public" {
    count                       = length(var.public_subnet_cidrs)                               # Number of public subnets to create

    vpc_id                      = aws_vpc.this.id                                               # ID of the VPC to create the subnets in
    cidr_block                  = element(var.public_subnet_cidrs, count.index)                 # CIDR block for each public subnet
    ipv6_cidr_block             = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index + 11) # IPv6 CIDR block for each public subnet, 11 - take just to correspond with ipv4 template "10.40.11.0/24"
    availability_zone           = data.aws_availability_zones.zone.names[0]                     # Availability zone for each public subnet
    map_public_ip_on_launch     = true                                                          # !!! Important - assign public IP address to instances in the public subnet by default

    tags = {
        Name = "${var.env} Public subnet ${element(local.alphabet, count.index)}"               # Instead of numbering in digits, it will be in letters "Public subnet A, B, C..."""
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.this.id              #IPv4 goes through IGW
    }
    route {
        ipv6_cidr_block     = "::/0"
        gateway_id          = aws_internet_gateway.this.id              #IPv6 goes through IGW
    }

    tags = {
            Name = "${var.env} Public"
        }
}

resource "aws_route_table_association" "public_routes" {
    count               = length(aws_subnet.public[*].id)               # Number of public subnet IDs    

    route_table_id      = aws_route_table.public.id                     # ID of the public route table for each subnet
    subnet_id           = element(aws_subnet.public[*].id, count.index) # ID of each public subnet
}

#-----------------------------NAT gateways with EIP ------------------------------------

resource "aws_eip" "nat" {
    vpc     = true

    tags = {
        Name = "${var.env} for NAT Gateway"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id   = aws_eip.nat.id                # ID of the Elastic IP address for the NAT gateway
    subnet_id       = aws_subnet.private[0].id      # ID of the first private subnet to attach the NAT gateway to


    tags = {
        Name  = "${var.env} NAT Gateway"            # Name of the NAT gateway based on the environment
    }
}

#-------------------------Private Subnets and Routes------------------------------------

resource "aws_subnet" "private" {
    count                       = length(var.private_subnet_cidrs)                                  # Number of private subnets to create

    vpc_id                      = aws_vpc.this.id                                                   # ID of the VPC to create the subnets in
    cidr_block                  = element(var.private_subnet_cidrs, count.index)                    # CIDR block for each public subnet
    ipv6_cidr_block             = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index + 21)     # IPv6 CIDR block for each private subnet, 21 - take just to correspond with ipv4 template "10.40.21.0/24"
    availability_zone           = data.aws_availability_zones.zone.names[0]                         # Availability zone for each public subnet

    tags = {
        Name = "${var.env} private App subnet ${element(local.alphabet, count.index)}"              # Instead of numbering in digits, it will be in letters "private App subnet A, B, C..."""
    }
}

resource "aws_route_table" "private" {
    count           = length(var.private_subnet_cidrs)

    vpc_id          = aws_vpc.this.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_nat_gateway.nat.id                                #IPv4 goes through NAT
    }
    route {
        ipv6_cidr_block        = "::/0"
        egress_only_gateway_id = aws_egress_only_internet_gateway.this.id   #IPv6 goes through EIGW
    }

        tags = {
            Name  = "${var.env} route private App subnet ${element(local.alphabet, count.index)}"
        }
}

resource "aws_route_table_association" "private" {
    count           = length(aws_subnet.private[*].id)                  # Number of private subnet IDs

    route_table_id  = aws_route_table.private[count.index].id           # ID of the private route table for each subnet
    subnet_id       = element(aws_subnet.private[*].id, count.index)    # ID of each private subnet
}
