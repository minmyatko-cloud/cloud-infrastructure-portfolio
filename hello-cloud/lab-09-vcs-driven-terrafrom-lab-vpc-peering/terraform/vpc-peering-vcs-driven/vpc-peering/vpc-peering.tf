resource "aws_vpc_peering_connection" "fevpc_peering_bevpc" {
  vpc_id      = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_vpc_id
  peer_vpc_id = data.tfe_outputs.be_network_ws.nonsensitive_values.backend_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "fevpc_private_subnet02_to_bevpc_private_subnet02" {
  route_table_id            = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_routetable02_id
  destination_cidr_block    = data.tfe_outputs.be_network_ws.nonsensitive_values.backend_private_subnets_cidr_blocks["private_subnet_2"]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "bevpc_private_subnet02_to_fevpc_private_subnet02" {
  route_table_id            = data.tfe_outputs.be_network_ws.nonsensitive_values.backend_private_routetable02_id
  destination_cidr_block    = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_subnets_cidr_blocks["private_subnet_2"]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "fevpc_private_subnet03_to_bevpc_private_subnet03" {
  route_table_id            = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_routetable03_id
  destination_cidr_block    = data.tfe_outputs.be_network_ws.nonsensitive_values.backend_private_subnets_cidr_blocks["private_subnet_3"]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "bevpc_private_subnet03_to_fevpc_private_subnet03" {
  route_table_id            = data.tfe_outputs.be_network_ws.nonsensitive_values.backend_private_routetable03_id
  destination_cidr_block    = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_subnets_cidr_blocks["private_subnet_3"]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}
