#####################################################################
# Private Instance AMI (ubuntu)
#####################################################################

data "aws_ami" "fe_private_instance_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20261017"]
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

#####################################################################
# Private Instances
#####################################################################
resource "aws_instance" "frontend_private_instance01" {
  ami                    = data.aws_ami.fe_private_instance_ami.id
  instance_type          = var.fe_instance_type
  key_name               = aws_key_pair.fe_keypair.key_name
  subnet_id              = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_subnet01_id
  vpc_security_group_ids = [data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg01_id]

  tags = {
    Name        = "${var.frontend_prefix}-private-instance01"
    environment = "${var.frontend_environment}"
  }
}


resource "aws_instance" "frontend_private_instance02" {
  ami                    = data.aws_ami.fe_private_instance_ami.id
  instance_type          = var.fe_instance_type
  key_name               = aws_key_pair.fe_keypair.key_name
  subnet_id              = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_subnet02_id
  vpc_security_group_ids = [data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg02_id]

  tags = {
    Name        = "${var.frontend_prefix}-private-instance02"
    environment = "${var.frontend_environment}"
  }
}

resource "aws_instance" "frontend_private_instance03" {
  ami                    = data.aws_ami.fe_private_instance_ami.id
  instance_type          = var.fe_instance_type
  key_name               = aws_key_pair.fe_keypair.key_name
  subnet_id              = data.tfe_outputs.fe_network_ws.nonsensitive_values.frontend_private_subnet03_id
  vpc_security_group_ids = [data.tfe_outputs.fe_security_ws.nonsensitive_values.frontend_private_sg03_id]

  tags = {
    Name        = "${var.frontend_prefix}-private-instance03"
    environment = "${var.frontend_environment}"
  }
}