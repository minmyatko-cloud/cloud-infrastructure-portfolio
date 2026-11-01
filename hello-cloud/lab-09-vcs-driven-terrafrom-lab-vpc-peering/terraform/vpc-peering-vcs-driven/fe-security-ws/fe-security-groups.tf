
#############################################################
#Frontend Public Security Group and IB/OB Rules
#############################################################

resource "aws_security_group" "fe_public_sg01" {
  name = "${var.frontend_prefix}-public-security-group01"

  vpc_id = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_vpc_id

  tags = {
    Name = "${var.frontend_prefix}-public-security-group01"
    Environment = var.frontend_environment
  }
 }
resource "aws_vpc_security_group_ingress_rule" "fe_public_sg01_allow_ssh" {
  security_group_id            = aws_security_group.fe_public_sg01.id
  cidr_ipv4                    = var.allow_ip_from_public_users
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_public_sg01_allow_icmp" {
  security_group_id            = aws_security_group.fe_public_sg01.id
  cidr_ipv4                    = var.allow_ip_from_public_users
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}


resource "aws_vpc_security_group_egress_rule" "fe_public_sg01_allow_all_traffic" {
  security_group_id = aws_security_group.fe_public_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##############################################################
#Frontend Private Security Group 1 & Inbound/Outbound Rules
##############################################################


resource "aws_security_group" "fe_private_sg01" {
  name = "${var.frontend_prefix}-private-security-group01"

  vpc_id = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg01_allow_ssh" {
  security_group_id            = aws_security_group.fe_private_sg01.id
  referenced_security_group_id = aws_security_group.fe_public_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg01_allow_icmp" {
  security_group_id            = aws_security_group.fe_private_sg01.id
  referenced_security_group_id = aws_security_group.fe_public_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg01_allow_all_traffic" {
  security_group_id = aws_security_group.fe_private_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##############################################################
#Frontend Private Security Group 2 & Inbound/Outbound Rules
##############################################################

resource "aws_security_group" "fe_private_sg02" {
  name = "${var.frontend_prefix}-private-security-group02"

  vpc_id = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group02"
    Environment = var.frontend_environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_ssh_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg02.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_icmp_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg02.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}



##############################################################
#Frontend Private Security Group 3 & Inbound/Outbound Rules
##############################################################

resource "aws_security_group" "fe_private_sg03" {
  name = "${var.frontend_prefix}-private-security-group03"

  vpc_id = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group03"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_ssh_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg03.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_icmp_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg03.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}
