output "fe_private_key_pem" {
  description = "frontend_ssh_private_key"
  value       = tls_private_key.fe_keypair.private_key_pem
  sensitive    = true
}

output "fe_private_instance_ips" {
  description = "Private IP addresses of frontend instances"
  value = {
    instance_01 = aws_instance.frontend_private_instance01.private_ip
    instance_02 = aws_instance.frontend_private_instance02.private_ip
    instance_03 = aws_instance.frontend_private_instance03.private_ip
  }
}