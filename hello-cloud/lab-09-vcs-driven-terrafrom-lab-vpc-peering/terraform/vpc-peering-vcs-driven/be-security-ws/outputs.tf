
output "backend_public_sg01_id" {
  description = "public security group_01 ID of the backend workspace"
  value       = aws_security_group.be_public_sg01.id
}


output "backend_private_sg01_id" {
  description = "private security group_01 ID of the backend workspace"
  value       = aws_security_group.be_private_sg01.id
}

output "backend_private_sg02_id" {
  description = "private security group_02 ID of the backend workspace"
  value       = aws_security_group.be_private_sg02.id
}

output "backend_private_sg03_id" {
  description = "private security group_02 ID of the backend workspace"
  value       = aws_security_group.be_private_sg03.id
}