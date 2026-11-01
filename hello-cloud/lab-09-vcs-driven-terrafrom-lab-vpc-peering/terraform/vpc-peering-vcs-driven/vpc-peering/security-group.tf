
# fe-securty-group (inbound from backend and outbound to backend)

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_ssh_from_be_private_sg02" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  referenced_security_group_id = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_icmp_from_be_private_sg02" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  referenced_security_group_id = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg02_allow_ssh_to_be_private_instance_02" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  cidr_ipv4                    = "${data.tfe_outputs.be_compute_ws.nonsensitive_values.be_private_instance_ips["instance_02"]}/32"
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg02_allow_icmp_to_be_private_instance_02" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  cidr_ipv4                    = "${data.tfe_outputs.be_compute_ws.nonsensitive_values.be_private_instance_ips["instance_02"]}/32"
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_ssh_from_be_private_sg03" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  referenced_security_group_id = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_icmp_from_be_private_sg03" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  referenced_security_group_id = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg03_allow_ssh_to_be_private_instance_03" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  cidr_ipv4                    = "${data.tfe_outputs.be_compute_ws.nonsensitive_values.be_private_instance_ips["instance_03"]}/32"
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg03_allow_icmp_to_be_private_instance_03" {
  security_group_id            = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  cidr_ipv4                    = "${data.tfe_outputs.be_compute_ws.nonsensitive_values.be_private_instance_ips["instance_03"]}/32"
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

# Be-Secuirty-Group

resource "aws_vpc_security_group_ingress_rule" "be_private_sg02_allow_ssh_from_fe_private_sg02" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  referenced_security_group_id = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_ingress_rule" "be_private_sg02_allow_icmp_from_fe_private_sg02" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  referenced_security_group_id = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg02_allow_ssh_to_fe_instance_02" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  cidr_ipv4                    = "${data.tfe_outputs.fe_compute_ws.nonsensitive_values.fe_private_instance_ips["instance_02"]}/32"
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg02_allow_icmp_to_fe_instance_2" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg02_id
  cidr_ipv4                    = "${data.tfe_outputs.fe_compute_ws.nonsensitive_values.fe_private_instance_ips["instance_02"]}/32"
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_ingress_rule" "be_private_sg03_allow_ssh_from_fe_private_sg03" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  referenced_security_group_id = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_ingress_rule" "be_private_sg03_allow_icmp_from_fe_private_sg03" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  referenced_security_group_id = data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg03_allow_ssh_to_fe_instance_3" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  cidr_ipv4                    = "${data.tfe_outputs.fe_compute_ws.nonsensitive_values.fe_private_instance_ips["instance_03"]}/32"
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg03_allow_icmp_to_fe_instance_3" {
  security_group_id            = data.tfe_outputs.be_security_ws.nonsensitive_values.backend_private_sg03_id
  cidr_ipv4                   = "${data.tfe_outputs.fe_compute_ws.nonsensitive_values.fe_private_instance_ips["instance_03"]}/32"
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0

  depends_on = [aws_vpc_peering_connection.fevpc_peering_bevpc]
}