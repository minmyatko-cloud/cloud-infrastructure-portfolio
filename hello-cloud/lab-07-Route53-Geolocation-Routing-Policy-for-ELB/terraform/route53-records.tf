
# Asia → Singapore Geo-location routing policy and Route53 record

resource "aws_route53_record" "geo_asia" {
  provider = aws

  zone_id        = aws_route53_zone.geo.zone_id
  name           = "geo.minracle.com"
  type           = "A"
  set_identifier = "asia-singapore"

  geolocation_routing_policy {
    continent = "AS"
  }

  alias {
    name                   = aws_lb.sg_web_alb.dns_name
    zone_id                = aws_lb.sg_web_alb.zone_id
    evaluate_target_health = true
  }
}

# --------------------------------------------------
# Europe → London Geo-location routing policy and Route53 record
# --------------------------------------------------

resource "aws_route53_record" "geo_europe" {
  provider = aws

  zone_id        = aws_route53_zone.geo.zone_id
  name           = "geo.minracle.com"
  type           = "A"
  set_identifier = "europe-london"

  geolocation_routing_policy {
    continent = "EU"
  }

  alias {
    name                   = aws_lb.lon_web_alb.dns_name
    zone_id                = aws_lb.lon_web_alb.zone_id
    evaluate_target_health = true
  }
}

# --------------------------------------------------
# North America → Northern California Geo-location routing policy and Route53 record
# --------------------------------------------------

resource "aws_route53_record" "geo_north_america" {
  provider = aws

  zone_id        = aws_route53_zone.geo.zone_id
  name           = "geo.minracle.com"
  type           = "A"
  set_identifier = "north-america-california"

  geolocation_routing_policy {
    continent = "NA"
  }

  alias {
    name                   = aws_lb.nca_web_alb.dns_name
    zone_id                = aws_lb.nca_web_alb.zone_id
    evaluate_target_health = true
  }
}

# --------------------------------------------------
# Default → Singapore
# --------------------------------------------------

resource "aws_route53_record" "geo_default" {
  provider = aws

  zone_id        = aws_route53_zone.geo.zone_id
  name           = "geo.minracle.com"
  type           = "A"
  set_identifier = "default-singapore"

  geolocation_routing_policy {
    country = "*"
  }

  alias {
    name                   = aws_lb.sg_web_alb.dns_name
    zone_id                = aws_lb.sg_web_alb.zone_id
    evaluate_target_health = true
  }
}