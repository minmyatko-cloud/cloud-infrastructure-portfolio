# Singapore Internet Gateway

resource "aws_internet_gateway" "sg" {
  vpc_id = aws_vpc.sg.id

  tags = {
    Name = "ig-sg"
  }
}

# london Internet Gateway

resource "aws_internet_gateway" "lon" {
  provider = aws.london
  vpc_id   = aws_vpc.lon.id

  tags = {
    Name = "ig-lon"
  }
}

# Northern California Internet Gateway

resource "aws_internet_gateway" "nca" {
  provider = aws.california
  vpc_id   = aws_vpc.nca.id

  tags = {
    Name = "ig-nca"
  }
}
