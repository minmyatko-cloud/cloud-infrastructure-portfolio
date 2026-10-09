
# Singapore

resource "aws_instance" "sg_web" {
  provider = aws

  for_each = {
    "sg-web-svr-1" = {
      subnet_id        = aws_subnet.private_subnet_1_sg.id
      server_label     = "Singapore Web Server 1"
      background_color = "#D1FAE5"
    }
    "sg-web-svr-2" = {
      subnet_id        = aws_subnet.private_subnet_2_sg.id
      server_label     = "Singapore Web Server 2"
      background_color = "#DBEAFE"
    }
  }

  ami                         = data.aws_ami.sg.id
  instance_type               = "t3.micro"
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.web_server_sg_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.web_server.name

  user_data = templatefile(
    "${path.module}/templates/web-user-data.sh.tftpl",
    {
      aws_region       = "ap-southeast-1"
      secret_name      = "lab-07-route53-geolocation/${each.key}/tls"
      server_label     = each.value.server_label
      background_color = each.value.background_color
    }
  )

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = each.key
  }

  depends_on = [
    aws_route.private_route_sg,
    aws_route_table_association.private_subnet_1_rt_assoc_sg,
    aws_route_table_association.private_subnet_2_rt_assoc_sg,
    aws_vpc_security_group_egress_rule.outbound_web_server_sg_sg
  ]
}

# London Web Server Instances

resource "aws_instance" "lon_web" {
  provider = aws.london

  for_each = {
    "lon-web-svr-1" = {
      subnet_id        = aws_subnet.private_subnet_1_lon.id
      server_label     = "London Web Server 1"
      background_color = "#EDE9FE"
    }
    "lon-web-svr-2" = {
      subnet_id        = aws_subnet.private_subnet_2_lon.id
      server_label     = "London Web Server 2"
      background_color = "#FCE7F3"
    }
  }

  ami                         = data.aws_ami.lon.id
  instance_type               = "t3.micro"
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.web_server_lon_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.web_server.name

  user_data = templatefile(
    "${path.module}/templates/web-user-data.sh.tftpl",
    {
      aws_region       = "eu-west-2"
      secret_name      = "lab-07-route53-geolocation/${each.key}/tls"
      server_label     = each.value.server_label
      background_color = each.value.background_color
    }
  )

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = each.key
  }

  depends_on = [
    aws_route.private_route_lon,
    aws_route_table_association.private_subnet_1_rt_assoc_lon,
    aws_route_table_association.private_subnet_2_rt_assoc_lon,
    aws_vpc_security_group_egress_rule.outbound_web_server_lon
  ]
}

# Northern California


resource "aws_instance" "nca_web" {
  provider = aws.california

  for_each = {
    "nca-web-svr-1" = {
      subnet_id        = aws_subnet.private_subnet_1_nca.id
      server_label     = "Northern California Web Server 1"
      background_color = "#FFEDD5"
    }
    "nca-web-svr-2" = {
      subnet_id        = aws_subnet.private_subnet_2_nca.id
      server_label     = "Northern California Web Server 2"
      background_color = "#FEF9C3"
    }
  }

  ami                         = data.aws_ami.nca.id
  instance_type               = "t3.micro"
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.web_server_nca_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.web_server.name

  user_data = templatefile(
    "${path.module}/templates/web-user-data.sh.tftpl",
    {
      aws_region       = "us-west-1"
      secret_name      = "lab-07-route53-geolocation/${each.key}/tls"
      server_label     = each.value.server_label
      background_color = each.value.background_color
    }
  )

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = each.key
  }

  depends_on = [
    aws_route.private_route_nca,
    aws_route_table_association.private_subnet_1_rt_assoc_nca,
    aws_route_table_association.private_subnet_2_rt_assoc_nca,
    aws_vpc_security_group_egress_rule.outbound_web_server_nca
  ]
}