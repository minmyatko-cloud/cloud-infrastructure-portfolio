# singapore public subnets

resource "aws_subnet" "public_subnet_1_sg" {
  vpc_id                  = aws_vpc.sg.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 1 - sg"
  }
}

resource "aws_subnet" "public_subnet_2_sg" {
  vpc_id                  = aws_vpc.sg.id
  cidr_block              = "10.10.4.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 2 - sg"
  }
}

# singapore private subnets

resource "aws_subnet" "private_subnet_1_sg" {
  vpc_id            = aws_vpc.sg.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Private Subnet 1 - sg"
  }
}

resource "aws_subnet" "private_subnet_2_sg" {
  vpc_id            = aws_vpc.sg.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "Private Subnet 2 - sg"
  }
}

# london public subnets

resource "aws_subnet" "public_subnet_1_lon" {
  provider                = aws.london
  vpc_id                  = aws_vpc.lon.id
  cidr_block              = "172.16.3.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 1 - lon"
  }
}

resource "aws_subnet" "public_subnet_2_lon" {
  provider                = aws.london
  vpc_id                  = aws_vpc.lon.id
  cidr_block              = "172.16.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 2 - lon"
  }
}
# london private subnets

resource "aws_subnet" "private_subnet_1_lon" {
  provider          = aws.london
  vpc_id            = aws_vpc.lon.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Private Subnet 1 - lon"
  }
}

resource "aws_subnet" "private_subnet_2_lon" {
  provider          = aws.london
  vpc_id            = aws_vpc.lon.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Private Subnet 2 - lon"
  }
}

# Northern California public subnets

resource "aws_subnet" "public_subnet_1_nca" {
  provider                = aws.california
  vpc_id                  = aws_vpc.nca.id
  cidr_block              = "192.168.3.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 1 - nca"
  }
}

resource "aws_subnet" "public_subnet_2_nca" {
  provider                = aws.california
  vpc_id                  = aws_vpc.nca.id
  cidr_block              = "192.168.4.0/24"
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = false


  tags = {
    Name = "Public Subnet 2 - nca"
  }
}

# Northern California private subnets

resource "aws_subnet" "private_subnet_1_nca" {
  provider          = aws.california
  vpc_id            = aws_vpc.nca.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "Private Subnet 1 - nca"
  }
}

resource "aws_subnet" "private_subnet_2_nca" {
  provider          = aws.california
  vpc_id            = aws_vpc.nca.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-1c"

  tags = {
    Name = "Private Subnet 2 - nca"
  }
}