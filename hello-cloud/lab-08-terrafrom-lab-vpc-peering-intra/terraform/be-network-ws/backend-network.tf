#############################################################
# backend VPC 
#############################################################

resource "aws_vpc" "backend_vpc" {

  cidr_block           = var.backend_vpc_address_space
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.backend_prefix}-vpc"
    environment = "${var.backend_environment}"
  }
}

#############################################################
# public subnet
#############################################################

resource "aws_subnet" "backend_public_subnet01" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.backend_public_subnet_cidr[0]

  tags = {
    Name = "${var.backend_prefix}-public-subnet01-${var.region}"
  }
}

resource "aws_subnet" "backend_public_subnet02" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[1]
  cidr_block = var.backend_public_subnet_cidr[1]

  tags = {
    Name = "${var.backend_prefix}-public-subnet02-${var.region}"
  }
}

resource "aws_subnet" "backend_public_subnet03" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[2]
  cidr_block = var.backend_public_subnet_cidr[2]

  tags = {
    Name = "${var.backend_prefix}-public-subnet03-${var.region}"
  }
}

#############################################################
# IGW and Public Route Table, subnet association
#############################################################

resource "aws_internet_gateway" "backend_igw" {
  vpc_id = aws_vpc.backend_vpc.id

  tags = {
    Name = "${var.backend_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "backend_public_rtb" {
  vpc_id = aws_vpc.backend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backend_igw.id
  }

  tags = {
    Name = "${var.backend_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "backend_public_subnet01_association" {
  subnet_id      = aws_subnet.backend_public_subnet01.id
  route_table_id = aws_route_table.backend_public_rtb.id
}

resource "aws_route_table_association" "backend_public_subnet02_association" {
  subnet_id      = aws_subnet.backend_public_subnet02.id
  route_table_id = aws_route_table.backend_public_rtb.id
}

resource "aws_route_table_association" "backend_public_subnet03_association" {
  subnet_id      = aws_subnet.backend_public_subnet03.id
  route_table_id = aws_route_table.backend_public_rtb.id
}

#############################################################
# NAT Gateway and EIP
#############################################################

resource "aws_eip" "backend_natgw_eip" {

  tags = {
    name        = "${var.backend_prefix}-natgw-eip-${var.region}"
    environment = "${var.backend_environment}"
  }
}

resource "aws_nat_gateway" "backend_ngw" {

  allocation_id = aws_eip.backend_natgw_eip.id
  subnet_id     = aws_subnet.backend_public_subnet01.id

  depends_on = [
    aws_eip.backend_natgw_eip
  ]

  tags = {
    name        = "${var.backend_prefix}-natgw-${var.region}"
    environment = "${var.backend_environment}"
  }
}

#############################################################
# Private Subnet
#############################################################

resource "aws_subnet" "backend_private_subnet01" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.backend_private_subnet_cidr[0]

  tags = {
    Name = "${var.backend_prefix}-private-subnet01-${var.region}"
  }
}

resource "aws_subnet" "backend_private_subnet02" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[1]
  cidr_block = var.backend_private_subnet_cidr[1]

  tags = {
    Name = "${var.backend_prefix}-private-subnet02-${var.region}"
  }
}

resource "aws_subnet" "backend_private_subnet03" {
  vpc_id     = aws_vpc.backend_vpc.id
  availability_zone = var.availability_zone[2]
  cidr_block = var.backend_private_subnet_cidr[2]

  tags = {
    Name = "${var.backend_prefix}-private-subnet03-${var.region}"
  }
}

#############################################################
# NAT Gateway and Private Route Table 1, subnet association
#############################################################


resource "aws_route_table" "backend_private_rtb01" {
  vpc_id = aws_vpc.backend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.backend_ngw.id
  }

  tags = {
    Name = "${var.backend_prefix}-private-rtb01"
  }
}

resource "aws_route_table_association" "backend_private_subnet01_association" {
  subnet_id      = aws_subnet.backend_private_subnet01.id
  route_table_id = aws_route_table.backend_private_rtb01.id
}

#############################################################
# Private Route Table 2 & subnet association
#############################################################

resource "aws_route_table" "backend_private_rtb02" {
  vpc_id = aws_vpc.backend_vpc.id

  tags = {
    Name = "${var.backend_prefix}-private-rtb02"
  }
}

resource "aws_route_table_association" "backend_private_subnet02_association" {
  subnet_id      = aws_subnet.backend_private_subnet02.id
  route_table_id = aws_route_table.backend_private_rtb02.id
}

resource "aws_route_table" "backend_private_rtb03" {
  vpc_id = aws_vpc.backend_vpc.id

  tags = {
    Name = "${var.backend_prefix}-private-rtb03"
  }
}

resource "aws_route_table_association" "backend_private_subnet03_association" {
  subnet_id      = aws_subnet.backend_private_subnet03.id
  route_table_id = aws_route_table.backend_private_rtb03.id
}

