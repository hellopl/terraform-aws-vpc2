# This block defines a list of alphabet letters, to be used later for naming subnets
locals {
  alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
}

# This block retrieves the availability zones for the defined region 
data "aws_availability_zones" "zone" {}

# This block creates a VPC
resource "aws_vpc" "this" {
    cidr_block                          = var.vpc_cidr
    assign_generated_ipv6_cidr_block    = true

    tags = {
        Name = "${var.env} vpc2"
    }
}

# This block creates an egress-only internet gateway for the VPC
resource "aws_egress_only_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.env} eigw"
    }
}


# This block creates an internet gateway for the VPC
resource "aws_internet_gateway" "this" {
    vpc_id  = aws_vpc.this.id

    tags = {
        Name = "${var.env} igw"
    }
}


#-------Public subnets with route table--------------------------


# This block creates public subnets with a default route to the internet gateway
resource "aws_subnet" "public" {
    count                       = length(var.public_subnet_cidrs)

    vpc_id                      = aws_vpc.this.id
    cidr_block                  = element(var.public_subnet_cidrs, count.index)
    ipv6_cidr_block             = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index + 11)
    availability_zone           = data.aws_availability_zones.zone.names[0]
    map_public_ip_on_launch     = true

    tags = {
        Name = "${var.env} Public subnet ${element(local.alphabet, count.index)}"
    }
}

# This block creates a route table for the public subnets and adds a default route to the internet gateway
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.this.id
    }
    route {
        ipv6_cidr_block     = "::/0"
        gateway_id          = aws_internet_gateway.this.id
    }

    tags = {
            Name = "${var.env} Public"
        }
}

resource "aws_route_table_association" "public_routes" {
    count               = length(aws_subnet.public[*].id)

    route_table_id      = aws_route_table.public.id
    subnet_id           = element(aws_subnet.public[*].id, count.index)
}

#-----------------------------NAT gateways with EIP ------------------------------------

resource "aws_eip" "nat" {
    vpc     = true

    tags = {
        Name = "${var.env} natgw"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id   = aws_eip.nat.id
    subnet_id       = aws_subnet.private[0].id

    tags = {
        Name  = "${var.env} nat gw"
    }
}

#-------------------------Private Subnets and Routes------------------------------------

# Create private subnets and assign IPv4 and IPv6 CIDR blocks
resource "aws_subnet" "private" {
    count                       = length(var.private_subnet_cidrs)

    vpc_id                      = aws_vpc.this.id
    cidr_block                  = element(var.private_subnet_cidrs, count.index)
    ipv6_cidr_block             = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index + 21)
    availability_zone           = data.aws_availability_zones.zone.names[0]

    tags = {
        Name = "${var.env} private App subnet ${element(local.alphabet, count.index)}"
    }
}

# Create private route tables
resource "aws_route_table" "private" {
    count           = length(var.private_subnet_cidrs)

    vpc_id          = aws_vpc.this.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_nat_gateway.nat.id
    }
    route {
        ipv6_cidr_block        = "::/0"
        egress_only_gateway_id = aws_egress_only_internet_gateway.this.id
    }

        tags = {
            Name  = "${var.env} route private App subnet ${element(local.alphabet, count.index)}"
        }
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
    count           = length(aws_subnet.private[*].id)

    route_table_id  = aws_route_table.private[count.index].id
    subnet_id       = element(aws_subnet.private[*].id, count.index)
}
