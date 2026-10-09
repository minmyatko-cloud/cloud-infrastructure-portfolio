# singapore VPC
resource "aws_vpc" "sg" {
  cidr_block           = "10.10.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  region               = "ap-southeast-1"

  tags = {
    Name = "vpc-sg"
  }
}

# london VPC
resource "aws_vpc" "lon" {
  provider = aws.london

  cidr_block           = "172.16.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  region               = "eu-west-2"

  tags = {
    Name = "vpc-lon"
  }
}

# Northern California VPC
resource "aws_vpc" "nca" {
  provider = aws.california

  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  region               = "us-west-1"

  tags = {
    Name = "vpc-nca"
  }
}