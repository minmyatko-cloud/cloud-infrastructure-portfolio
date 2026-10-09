# Singapore Private Route Table

resource "aws_route_table" "private_rt_sg" {
  vpc_id = aws_vpc.sg.id

  tags = {
    Name = "private-rt-sg"
  }
}
resource "aws_route" "private_route_sg" {
  route_table_id         = aws_route_table.private_rt_sg.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw_sg.id
}
resource "aws_route_table_association" "private_subnet_1_rt_assoc_sg" {
  subnet_id      = aws_subnet.private_subnet_1_sg.id
  route_table_id = aws_route_table.private_rt_sg.id
}
resource "aws_route_table_association" "private_subnet_2_rt_assoc_sg" {
  subnet_id      = aws_subnet.private_subnet_2_sg.id
  route_table_id = aws_route_table.private_rt_sg.id
}

# London Private Route Table

resource "aws_route_table" "private_rt_lon" {
  vpc_id   = aws_vpc.lon.id
  provider = aws.london

  tags = {
    Name = "private-rt-lon"
  }
}
resource "aws_route" "private_route_lon" {
  provider               = aws.london
  route_table_id         = aws_route_table.private_rt_lon.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw_lon.id
}
resource "aws_route_table_association" "private_subnet_1_rt_assoc_lon" {
  provider       = aws.london
  subnet_id      = aws_subnet.private_subnet_1_lon.id
  route_table_id = aws_route_table.private_rt_lon.id
}
resource "aws_route_table_association" "private_subnet_2_rt_assoc_lon" {
  provider       = aws.london
  subnet_id      = aws_subnet.private_subnet_2_lon.id
  route_table_id = aws_route_table.private_rt_lon.id
}

# Northern California Private Route Table

resource "aws_route_table" "private_rt_nca" {
  vpc_id   = aws_vpc.nca.id
  provider = aws.california

  tags = {
    Name = "private-rt-nca"
  }
}
resource "aws_route" "private_route_nca" {
  provider               = aws.california
  route_table_id         = aws_route_table.private_rt_nca.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw_nca.id
}
resource "aws_route_table_association" "private_subnet_1_rt_assoc_nca" {
  provider       = aws.california
  subnet_id      = aws_subnet.private_subnet_1_nca.id
  route_table_id = aws_route_table.private_rt_nca.id
}
resource "aws_route_table_association" "private_subnet_2_rt_assoc_nca" {
  provider       = aws.california
  subnet_id      = aws_subnet.private_subnet_2_nca.id
  route_table_id = aws_route_table.private_rt_nca.id
}




