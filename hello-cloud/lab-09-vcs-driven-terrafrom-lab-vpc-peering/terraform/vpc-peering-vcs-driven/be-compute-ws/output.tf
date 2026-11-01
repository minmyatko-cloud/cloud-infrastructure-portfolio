output "be_private_key_pem" {
  description = "backend_ssh_private_key"
  value       = tls_private_key.be_keypair.private_key_pem
  sensitive    = true
}

output "be_private_instance_ips" {
  description = "Private IP addresses of backend instances"
  value       = {
    instance_01= aws_instance.backend_private_instance01.private_ip
    instance_02= aws_instance.backend_private_instance02.private_ip
    instance_03= aws_instance.backend_private_instance03.private_ip
  }
}
