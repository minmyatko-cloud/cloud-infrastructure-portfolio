
output "frontend_public_sg01_id" {
  description = "public security group_01 ID of the frontend workspace"
  value       = aws_security_group.fe_public_sg01.id
}


output "frontend_private_sg01_id" {
  description = "private security group_01 ID of the frontend workspace"
  value       = aws_security_group.fe_private_sg01.id
}

output "frontend_private_sg02_id" {
  description = "private security group_02 ID of the frontend workspace"
  value       = aws_security_group.fe_private_sg02.id
}

output "frontend_private_sg03_id" {
  description = "private security group_02 ID of the frontend workspace"
  value       = aws_security_group.fe_private_sg03.id
}