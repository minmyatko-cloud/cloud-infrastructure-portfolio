resource "aws_route53_zone" "geo" {
  provider = aws

  name    = "geo.minracle.com"
  comment = "Public hosted zone for Route 53 geolocation lab"

  tags = {
    Name = "lab07-geolocation-zone"
  }
}