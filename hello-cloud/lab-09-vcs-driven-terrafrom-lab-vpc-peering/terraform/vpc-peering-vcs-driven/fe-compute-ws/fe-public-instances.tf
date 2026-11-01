#############################################################
# GET AMI from AWS
#############################################################

data "aws_ami" "fe_public_instance_ami" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }


  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#############################################################
# EIP Creation & Associate with public instance
#############################################################

resource "aws_eip" "frontend_public_instance_eip" {

  tags = {
    name        = "${var.frontend_prefix}-public-instance-eip-${var.region}"
    environment = "${var.frontend_environment}"
  }
}

resource "aws_eip_association" "fe_public_instance_eip_assoc" {
  instance_id   = aws_instance.frontend_public_instance01.id
  allocation_id = aws_eip.frontend_public_instance_eip.id
}

resource "aws_instance" "frontend_public_instance01" {
  ami                    = data.aws_ami.fe_public_instance_ami.id
  instance_type          = var.fe_instance_type
  key_name               = aws_key_pair.fe_keypair.key_name
  subnet_id              = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_public_subnet01_id
  availability_zone      = var.availability_zone_1
  vpc_security_group_ids = [data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_public_sg01_id]
  tags = {
    Name        = "${var.frontend_prefix}-public-instance01"
    environment = "${var.frontend_environment}"
  }
}
