
# Singapore
resource "aws_eip" "eip_sg" {
  domain = "vpc"

  tags = {
    Name = "eip-sg"
  }
}

resource "aws_nat_gateway" "nat_gw_sg" {
  allocation_id     = aws_eip.eip_sg.id
  subnet_id         = aws_subnet.public_subnet_1_sg.id
  connectivity_type = "public"

  tags = {
    Name = "nat-gw-sg"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sg]
}

# london

resource "aws_eip" "eip_lon" {
  provider = aws.london
  domain   = "vpc"

  tags = {
    Name = "eip-lon"
  }
}

resource "aws_nat_gateway" "nat_gw_lon" {
  provider          = aws.london
  allocation_id     = aws_eip.eip_lon.id
  subnet_id         = aws_subnet.public_subnet_1_lon.id
  connectivity_type = "public"

  tags = {
    Name = "nat-gw-lon"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.lon]
}

# North California

resource "aws_eip" "eip_nca" {
  provider = aws.california
  domain   = "vpc"

  tags = {
    Name = "eip-nca"
  }
}

resource "aws_nat_gateway" "nat_gw_nca" {
  provider          = aws.california
  allocation_id     = aws_eip.eip_nca.id
  subnet_id         = aws_subnet.public_subnet_1_nca.id
  connectivity_type = "public"

  tags = {
    Name = "nat-gw-nca"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.nca]
}


