
# Singapore target group and attachment

resource "aws_lb_target_group" "sg_web_server" {
  provider = aws

  name        = "lab07-sg-web-tg"
  vpc_id      = aws_vpc.sg.id
  target_type = "instance"
  protocol    = "HTTPS"
  port        = 443

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    port                = "traffic-port"
    path                = "/health.html"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lab07-sg-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "sg_web_server" {
  provider = aws
  for_each = aws_instance.sg_web

  target_group_arn = aws_lb_target_group.sg_web_server.arn
  target_id        = each.value.id
  port             = 443
}

# London target group and attachment

resource "aws_lb_target_group" "lon_web_server" {
  provider = aws.london

  name        = "lab07-lon-web-tg"
  vpc_id      = aws_vpc.lon.id
  target_type = "instance"
  protocol    = "HTTPS"
  port        = 443

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    port                = "traffic-port"
    path                = "/health.html"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lab07-lon-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "lon_web_server" {
  provider = aws.london
  for_each = aws_instance.lon_web

  target_group_arn = aws_lb_target_group.lon_web_server.arn
  target_id        = each.value.id
  port             = 443
}


# Northern California target group and attachment


resource "aws_lb_target_group" "nca_web_server" {
  provider = aws.california

  name        = "lab07-nca-web-tg"
  vpc_id      = aws_vpc.nca.id
  target_type = "instance"
  protocol    = "HTTPS"
  port        = 443

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    port                = "traffic-port"
    path                = "/health.html"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lab07-nca-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "nca_web" {
  provider = aws.california
  for_each = aws_instance.nca_web

  target_group_arn = aws_lb_target_group.nca_web_server.arn
  target_id        = each.value.id
  port             = 443
}