# Singapore Elastic Load Balancer


resource "aws_lb" "sg_web_alb" {
  provider = aws

  name               = "lab07-sg-web-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [
    aws_security_group.web_alb_sg_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1_sg.id,
    aws_subnet.public_subnet_2_sg.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "lab07-sg-web-alb"
  }

  depends_on = [
    aws_route.public_route_sg,
    aws_route_table_association.public_subnet_1_rt_assoc_sg,
    aws_route_table_association.public_subnet_2_rt_assoc_sg
  ]
}

# London Elastic Load Balancer


resource "aws_lb" "lon_web_alb" {
  provider = aws.london

  name               = "lab07-lon-web-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [
    aws_security_group.web_alb_lon_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1_lon.id,
    aws_subnet.public_subnet_2_lon.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "lab07-lon-web-alb"
  }

  depends_on = [
    aws_route.public_route_lon,
    aws_route_table_association.public_subnet_1_rt_assoc_lon,
    aws_route_table_association.public_subnet_2_rt_assoc_lon
  ]
}

# Northern California Elastic Load Balancer

resource "aws_lb" "nca_web_alb" {
  provider = aws.california

  name               = "lab07-nca-web-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [
    aws_security_group.web_alb_nca_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1_nca.id,
    aws_subnet.public_subnet_2_nca.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "lab07-nca-web-alb"
  }

  depends_on = [
    aws_route.public_route_nca,
    aws_route_table_association.public_subnet_1_rt_assoc_nca,
    aws_route_table_association.public_subnet_2_rt_assoc_nca
  ]
}