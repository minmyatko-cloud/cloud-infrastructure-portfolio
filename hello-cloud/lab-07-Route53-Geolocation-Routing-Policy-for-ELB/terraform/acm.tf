# Singapore AWS Certificate Manager (ACM) Certificate

data "aws_acm_certificate" "sg_alb" {
  provider = aws

  domain      = "geo.minracle.com"
  statuses    = ["ISSUED"]
  types       = ["IMPORTED"]
  most_recent = true

  tags = {
    Project = "lab-07-route53-geolocation"
  }
}


# London AWS Certificate Manager (ACM) Certificate


data "aws_acm_certificate" "lon_alb" {
  provider = aws.london

  domain      = "geo.minracle.com"
  statuses    = ["ISSUED"]
  types       = ["IMPORTED"]
  most_recent = true

  tags = {
    Project = "lab-07-route53-geolocation"
  }
}


# Northern California AWS Certificate Manager (ACM) Certificate 


data "aws_acm_certificate" "nca_alb" {
  provider = aws.california

  domain      = "geo.minracle.com"
  statuses    = ["ISSUED"]
  types       = ["IMPORTED"]
  most_recent = true

  tags = {
    Project = "lab-07-route53-geolocation"
  }
}