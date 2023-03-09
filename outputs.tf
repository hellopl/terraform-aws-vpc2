#Define output values
output "vpc_id" {
    description = "The ID of the VPC created"
    value = aws_vpc.this.id
}

output "vpc_cidr" {
    description = "The CIDR block of the VPC created"
    value = aws_vpc.this.cidr_block
}

output "public_subnets_ids" {
    description = "A list of IDs for the public subnets created"
    value = aws_subnet.public[*].id
}

output "private_subnets_ids" {
    description = "A list of IDs for the private subnets created"
    value = aws_subnet.private[*].id
}