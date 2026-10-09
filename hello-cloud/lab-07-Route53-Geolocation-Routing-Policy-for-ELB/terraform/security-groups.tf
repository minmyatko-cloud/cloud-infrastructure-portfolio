
# Singapore 

resource "aws_security_group" "web_alb_sg_sg" {
  name        = "web-alb-sg-sg"
  description = "Allow public HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.sg.id
  tags = {
    Name = "web-alb-sg-sg"
  }
}

resource "aws_security_group" "web_server_sg_sg" {
  name        = "web-server-sg-sg"
  description = "Allow HTTP and HTTPS inbound traffice from ALB and all outbound traffic"
  vpc_id      = aws_vpc.sg.id
  tags = {
    Name = "web-server-sg-sg"
  }
}

# ALB Security Group Rules Singapore

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_alb_sg" {
  security_group_id = aws_security_group.web_alb_sg_sg.id
  description       = "Allow HTTP and HTTP from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_to_alb_sg" {
  security_group_id = aws_security_group.web_alb_sg_sg.id
  description       = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_web_server_sg" {
  security_group_id            = aws_security_group.web_alb_sg_sg.id
  description                  = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  referenced_security_group_id = aws_security_group.web_server_sg_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

## Web Server Security Group Rules Singapore

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_sg" {
  security_group_id            = aws_security_group.web_server_sg_sg.id
  description                  = "Allow HTTP from inbound traffic  ALB"
  referenced_security_group_id = aws_security_group.web_alb_sg_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_alb_sg" {
  security_group_id            = aws_security_group.web_server_sg_sg.id
  description                  = "Allow HTTPS from inbound traffic from ALB"
  referenced_security_group_id = aws_security_group.web_alb_sg_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "outbound_web_server_sg_sg" {
  security_group_id = aws_security_group.web_server_sg_sg.id
  description       = "Allow pakckage installation and management"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}


# London

resource "aws_security_group" "web_alb_lon_sg" {
  provider    = aws.london
  name        = "web-alb-lon-sg"
  description = "Allow public HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.lon.id
  tags = {
    Name = "web-alb-lon-sg"
  }
}

resource "aws_security_group" "web_server_lon_sg" {
  provider    = aws.london
  name        = "web-server-lon-sg"
  description = "Allow HTTP and HTTPS inbound traffice from ALB and all outbound traffic"
  vpc_id      = aws_vpc.lon.id
  tags = {
    Name = "web-server-lon-sg"
  }
}

# ALB Security Group Rules

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_alb_lon" {
  provider          = aws.london
  security_group_id = aws_security_group.web_alb_lon_sg.id
  description       = "Allow HTTP and HTTP from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_to_alb_lon" {
  provider          = aws.london
  security_group_id = aws_security_group.web_alb_lon_sg.id
  description       = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_web_alb_lon" {
  provider                     = aws.london
  security_group_id            = aws_security_group.web_alb_lon_sg.id
  description                  = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  referenced_security_group_id = aws_security_group.web_server_lon_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

## Web Server Security Group Rules

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_lon" {
  provider                     = aws.london
  security_group_id            = aws_security_group.web_server_lon_sg.id
  description                  = "Allow HTTP from inbound traffic  ALB"
  referenced_security_group_id = aws_security_group.web_alb_lon_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_alb_lon" {
  provider                     = aws.london
  security_group_id            = aws_security_group.web_server_lon_sg.id
  description                  = "Allow HTTPS from inbound traffic from ALB"
  referenced_security_group_id = aws_security_group.web_alb_lon_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "outbound_web_server_lon" {
  security_group_id = aws_security_group.web_server_lon_sg.id
  provider          = aws.london
  description       = "Allow pakckage installation and management"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}

# North California

resource "aws_security_group" "web_alb_nca_sg" {
  provider    = aws.california
  name        = "web-alb-nca-sg"
  description = "Allow public HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.nca.id
  tags = {
    Name = "web-alb-nca-sg"
  }
}

resource "aws_security_group" "web_server_nca_sg" {
  provider    = aws.california
  name        = "web-server-nca-sg"
  description = "Allow HTTP and HTTPS inbound traffice from ALB and all outbound traffic"
  vpc_id      = aws_vpc.nca.id
  tags = {
    Name = "web-server-nca-sg"
  }
}

# ALB Security Group Rules

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_alb_nca" {
  provider          = aws.california
  security_group_id = aws_security_group.web_alb_nca_sg.id
  description       = "Allow HTTP and HTTP from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_to_alb_nca" {
  provider          = aws.california
  security_group_id = aws_security_group.web_alb_nca_sg.id
  description       = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_http_to_web_server_nca" {
  provider          = aws.california
  security_group_id = aws_security_group.web_alb_nca_sg.id
  description       = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_https_to_web_server_nca" {
  provider                     = aws.california
  security_group_id            = aws_security_group.web_alb_nca_sg.id
  description                  = "Allow HTTP and HTTPS from public  inbound traffic to ALB"
  referenced_security_group_id = aws_security_group.web_server_nca_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

## Web Server Security Group Rules

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_nca" {
  provider                     = aws.california
  security_group_id            = aws_security_group.web_server_nca_sg.id
  description                  = "Allow HTTP from inbound traffic  ALB"
  referenced_security_group_id = aws_security_group.web_alb_nca_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_alb_nca" {
  provider                     = aws.california
  security_group_id            = aws_security_group.web_server_nca_sg.id
  description                  = "Allow HTTPS from inbound traffic from ALB"
  referenced_security_group_id = aws_security_group.web_alb_nca_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "outbound_web_server_nca" {
  security_group_id = aws_security_group.web_server_nca_sg.id
  provider          = aws.california
  description       = "Allow pakckage installation and management"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}