# Singapore Public Route Table

resource "aws_route_table" "public_rt_sg" {
  vpc_id = aws_vpc.sg.id

  tags = {
    Name = "public-rt-sg"
  }
}
resource "aws_route" "public_route_sg" {
  route_table_id         = aws_route_table.public_rt_sg.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sg.id
}
resource "aws_route_table_association" "public_subnet_1_rt_assoc_sg" {
  subnet_id      = aws_subnet.public_subnet_1_sg.id
  route_table_id = aws_route_table.public_rt_sg.id
}
resource "aws_route_table_association" "public_subnet_2_rt_assoc_sg" {
  subnet_id      = aws_subnet.public_subnet_2_sg.id
  route_table_id = aws_route_table.public_rt_sg.id
}

# London Public Route TableTable

resource "aws_route_table" "public_rt_lon" {
  vpc_id   = aws_vpc.lon.id
  provider = aws.london

  tags = {
    Name = "public-rt-lon"
  }
}
resource "aws_route" "public_route_lon" {
  provider               = aws.london
  route_table_id         = aws_route_table.public_rt_lon.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lon.id
}
resource "aws_route_table_association" "public_subnet_1_rt_assoc_lon" {
  provider       = aws.london
  subnet_id      = aws_subnet.public_subnet_1_lon.id
  route_table_id = aws_route_table.public_rt_lon.id
}
resource "aws_route_table_association" "public_subnet_2_rt_assoc_lon" {
  provider       = aws.london
  subnet_id      = aws_subnet.public_subnet_2_lon.id
  route_table_id = aws_route_table.public_rt_lon.id
}

# Northern California Public Route TableTable

resource "aws_route_table" "public_rt_nca" {
  vpc_id   = aws_vpc.nca.id
  provider = aws.california

  tags = {
    Name = "public-rt-nca"
  }
}
resource "aws_route" "public_route_nca" {
  provider               = aws.california
  route_table_id         = aws_route_table.public_rt_nca.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nca.id
}
resource "aws_route_table_association" "public_subnet_1_rt_assoc_nca" {
  provider       = aws.california
  subnet_id      = aws_subnet.public_subnet_1_nca.id
  route_table_id = aws_route_table.public_rt_nca.id
}
resource "aws_route_table_association" "public_subnet_2_rt_assoc_nca" {
  provider       = aws.california
  subnet_id      = aws_subnet.public_subnet_2_nca.id
  route_table_id = aws_route_table.public_rt_nca.id
}




