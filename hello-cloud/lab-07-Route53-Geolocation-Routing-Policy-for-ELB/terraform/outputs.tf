
# Route 53


output "geo_name_servers" {
  description = "Name servers for delegating geo.minracle.com"
  value       = aws_route53_zone.geo.name_servers
}

output "geo_hosted_zone_id" {
  description = "Hosted zone ID for the geolocation records"
  value       = aws_route53_zone.geo.zone_id
}

output "website_url" {
  description = "Geolocation lab HTTPS URL"
  value       = "https://geo.minracle.com"
}


# Application Load Balancers


output "alb_dns_names" {
  description = "Regional ALB DNS names"

  value = {
    sg  = aws_lb.sg_web_alb.dns_name
    lon = aws_lb.lon_web_alb.dns_name
    nca = aws_lb.nca_web_alb.dns_name
  }
}


# EC2 instances


output "sg_instance_ids" {
  description = "Singapore web server instance IDs"

  value = {
    for name, instance in aws_instance.sg_web :
    name => instance.id
  }
}

output "lon_instance_ids" {
  description = "London web server instance IDs"

  value = {
    for name, instance in aws_instance.lon_web :
    name => instance.id
  }
}

output "nca_instance_ids" {
  description = "Northern California web server instance IDs"

  value = {
    for name, instance in aws_instance.nca_web :
    name => instance.id
  }
}