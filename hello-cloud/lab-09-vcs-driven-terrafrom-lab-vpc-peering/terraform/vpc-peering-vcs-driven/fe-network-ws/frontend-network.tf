#############################################################
# frontend VPC 
#############################################################

resource "aws_vpc" "frontend_vpc" {

  cidr_block           = var.frontend_vpc_address_space
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.frontend_prefix}-vpc"
    environment = "${var.frontend_environment}"
  }
}

#############################################################
# public subnet
#############################################################

resource "aws_subnet" "frontend_public_subnet01" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.frontend_public_subnet_cidr[0]

  tags = {
    Name = "${var.frontend_prefix}-public-subnet01-${var.region}"
  }
}

resource "aws_subnet" "frontend_public_subnet02" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[1]
  cidr_block = var.frontend_public_subnet_cidr[1]

  tags = {
    Name = "${var.frontend_prefix}-public-subnet02-${var.region}"
  }
}

resource "aws_subnet" "frontend_public_subnet03" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[2]
  cidr_block = var.frontend_public_subnet_cidr[2]

  tags = {
    Name = "${var.frontend_prefix}-public-subnet03-${var.region}"
  }
}

#############################################################
# IGW and Public Route Table, subnet association


resource "aws_internet_gateway" "frontend_igw" {
  vpc_id = aws_vpc.frontend_vpc.id

  tags = {
    Name = "${var.frontend_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "frontend_public_rtb" {
  vpc_id = aws_vpc.frontend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.frontend_igw.id
  }

  tags = {
    Name = "${var.frontend_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "frontend_public_subnet01_association" {
  subnet_id      = aws_subnet.frontend_public_subnet01.id
  route_table_id = aws_route_table.frontend_public_rtb.id
}

resource "aws_route_table_association" "frontend_public_subnet02_association" {
  subnet_id      = aws_subnet.frontend_public_subnet02.id
  route_table_id = aws_route_table.frontend_public_rtb.id
}

resource "aws_route_table_association" "frontend_public_subnet03_association" {
  subnet_id      = aws_subnet.frontend_public_subnet03.id
  route_table_id = aws_route_table.frontend_public_rtb.id
}

#############################################################
# NAT Gateway and EIP
#############################################################

resource "aws_eip" "frontend_natgw_eip" {

  tags = {
    name        = "${var.frontend_prefix}-natgw-eip-${var.region}"
    environment = "${var.frontend_environment}"
  }
}

resource "aws_nat_gateway" "frontend_ngw" {

  allocation_id = aws_eip.frontend_natgw_eip.id
  subnet_id     = aws_subnet.frontend_public_subnet01.id

  depends_on = [
    aws_eip.frontend_natgw_eip
  ]

  tags = {
    name        = "${var.frontend_prefix}-natgw-${var.region}"
    environment = "${var.frontend_environment}"
  }
}

#############################################################
# Private Subnet
#############################################################

resource "aws_subnet" "frontend_private_subnet01" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[0]
  cidr_block = var.frontend_private_subnet_cidr[0]

  tags = {
    Name = "${var.frontend_prefix}-private-subnet01-${var.region}"
  }
}

resource "aws_subnet" "frontend_private_subnet02" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[1]
  cidr_block = var.frontend_private_subnet_cidr[1]

  tags = {
    Name = "${var.frontend_prefix}-private-subnet02-${var.region}"
  }
}

resource "aws_subnet" "frontend_private_subnet03" {
  vpc_id     = aws_vpc.frontend_vpc.id
  availability_zone = var.availability_zone[2]
  cidr_block = var.frontend_private_subnet_cidr[2]

  tags = {
    Name = "${var.frontend_prefix}-private-subnet03-${var.region}"
  }
}

#############################################################
# NAT Gateway and Private Route Table 1, subnet association
#############################################################


resource "aws_route_table" "frontend_private_rtb01" {
  vpc_id = aws_vpc.frontend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.frontend_ngw.id
  }

  tags = {
    Name = "${var.frontend_prefix}-private-rtb01"
  }
}

resource "aws_route_table_association" "frontend_private_subnet01_association" {
  subnet_id      = aws_subnet.frontend_private_subnet01.id
  route_table_id = aws_route_table.frontend_private_rtb01.id
}

#############################################################
# Private Route Table 2 & subnet association
#############################################################

resource "aws_route_table" "frontend_private_rtb02" {
  vpc_id = aws_vpc.frontend_vpc.id

  tags = {
    Name = "${var.frontend_prefix}-private-rtb02"
  }
}

resource "aws_route_table_association" "frontend_private_subnet02_association" {
  subnet_id      = aws_subnet.frontend_private_subnet02.id
  route_table_id = aws_route_table.frontend_private_rtb02.id
}

resource "aws_route_table" "frontend_private_rtb03" {
  vpc_id = aws_vpc.frontend_vpc.id

  tags = {
    Name = "${var.frontend_prefix}-private-rtb03"
  }
}

resource "aws_route_table_association" "frontend_private_subnet03_association" {
  subnet_id      = aws_subnet.frontend_private_subnet03.id
  route_table_id = aws_route_table.frontend_private_rtb03.id
}

