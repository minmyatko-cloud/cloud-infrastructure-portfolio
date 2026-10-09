# Singapore add listener and redirect rule

resource "aws_lb_listener" "https_sg" {
  provider = aws

  load_balancer_arn = aws_lb.sg_web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.sg_alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sg_web_server.arn
  }
}

resource "aws_lb_listener" "http_sg" {
  provider = aws

  load_balancer_arn = aws_lb.sg_web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# London listerner and redirect rule


resource "aws_lb_listener" "https_lon" {
  provider = aws.london

  load_balancer_arn = aws_lb.lon_web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.lon_alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lon_web_server.arn
  }
}

resource "aws_lb_listener" "http_lon" {
  provider = aws.london

  load_balancer_arn = aws_lb.lon_web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Northern California listerner and redirect rule


resource "aws_lb_listener" "https_nca" {
  provider = aws.california

  load_balancer_arn = aws_lb.nca_web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.nca_alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nca_web_server.arn
  }
}

resource "aws_lb_listener" "http_nca" {
  provider = aws.california

  load_balancer_arn = aws_lb.nca_web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}