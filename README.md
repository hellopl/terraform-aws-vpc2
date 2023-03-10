# Terraform AWS VPC2

This Terraform template for creating a VPC2 (see below scheme) with public and private subnets across multiple availability zones in AWS. It also creates an Egress-only Internet Gateway and a NAT Gateway for the private subnets.

![Снимок экрана 2023-03-09 134903](https://user-images.githubusercontent.com/84510989/224281606-733f6f26-f4a3-4a44-9390-94ab2906dc05.png)

Inputs:
  env                   = "dev"
  vpc_cidr              = "10.40.0.0/16"
  public_subnet_cidrs   = ["10.40.11.0/24", "10.40.12.0/24", "10.40.13.0/24"]
  private_subnet_cidrs  = ["10.40.21.0/24", "10.40.22.0/24", "10.40.23.0/24"]
  
Outputs
  vpc_id	            - The ID of the VPC
  vpc_cidr            - The CIDR block of the VPC
  public_subnet_ids	  - The IDs of the public subnets
  private_subnet_ids	- The IDs of the private subnets


This VPC2 template is created and maintained by Pavel Sevko.
