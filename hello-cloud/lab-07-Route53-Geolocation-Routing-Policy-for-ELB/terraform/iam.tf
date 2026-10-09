# Allow EC2 instances to assume this role
resource "aws_iam_role" "web_server" {
  provider    = aws
  name        = "lab-07-route53-geolocation-web-role"
  description = "Systems Manager access for regional web servers"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "lab-07-web-role"
  }
}

# Grant the instances Systems Manager permissions
resource "aws_iam_role_policy_attachment" "web_server_ssm" {
  provider = aws

  role       = aws_iam_role.web_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Make the role available for attachment to EC2 instances
resource "aws_iam_instance_profile" "web_server" {
  provider = aws

  name = "lab-07-route53-geolocation-web-profile"
  role = aws_iam_role.web_server.name

  tags = {
    Name = "lab-07-web-profile"
  }

  depends_on = [
    aws_iam_role_policy_attachment.web_server_ssm
  ]
}
# Identify the AWS account used by Terraform
data "aws_caller_identity" "current" {
  provider = aws
}

# Allow the shared EC2 role to read the lab certificate bundles
resource "aws_iam_role_policy" "web_server_certificates" {
  provider = aws

  name = "lab-07-read-web-certificates"
  role = aws_iam_role.web_server.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadWebServerCertificates"
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"

        Resource = [
          "arn:aws:secretsmanager:ap-southeast-1:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/sg-web-svr-1/tls-??????",
          "arn:aws:secretsmanager:ap-southeast-1:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/sg-web-svr-2/tls-??????",
          "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/lon-web-svr-1/tls-??????",
          "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/lon-web-svr-2/tls-??????",
          "arn:aws:secretsmanager:us-west-1:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/nca-web-svr-1/tls-??????",
          "arn:aws:secretsmanager:us-west-1:${data.aws_caller_identity.current.account_id}:secret:lab-07-route53-geolocation/nca-web-svr-2/tls-??????"
        ]
      }
    ]
  })
}
