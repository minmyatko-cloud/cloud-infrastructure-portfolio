
output "frontend_vpc_id" {
  description = "VPC ID of the frontend instance"
  value       = aws_vpc.frontend_vpc.id
}


output "frontend_public_subnet01_id" {
  description = "Public Subnet01 ID of the frontend instance"
  value       = aws_subnet.frontend_public_subnet01.id
}

output "frontend_public_subnet02_id" {
  description = "Public Subnet02 ID of the frontend instance"
  value       = aws_subnet.frontend_public_subnet02.id
}

output "frontend_public_subnet03_id" {
  description = "Public Subnet03 ID of the frontend instance"
  value       = aws_subnet.frontend_public_subnet03.id
}

output "frontend_private_subnet01_id" {
  description = "Private Subnet01 ID of the frontend instance"
  value       = aws_subnet.frontend_private_subnet01.id
}

output "frontend_private_subnet02_id" {
  description = "Private Subnet02 ID of the frontend instance"
  value       = aws_subnet.frontend_private_subnet02.id
}

output "frontend_private_subnet03_id" {
  description = "Private Subnet03 ID of the frontend instance"
  value       = aws_subnet.frontend_private_subnet03.id
}

output "frontend_private_routetable02_id" {
  description = "Private Subnet02 ID of the frontend instance"
  value       = aws_route_table.frontend_private_rtb02.id
}

output "frontend_private_routetable03_id" {
  description = "Private Subnet03 ID of the frontend instance"
  value       = aws_route_table.frontend_private_rtb03.id
}

output "frontend_private_subnets_cidr_blocks" {
  value = {
    private_subnet_1 = aws_subnet.frontend_private_subnet01.cidr_block
    private_subnet_2 = aws_subnet.frontend_private_subnet02.cidr_block
    private_subnet_3 = aws_subnet.frontend_private_subnet03.cidr_block
  }
}
