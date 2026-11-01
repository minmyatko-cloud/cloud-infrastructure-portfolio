terraform {
  required_version = "~>1.16.5"

  cloud {

    organization = "minmyatko"

    workspaces {
      name = "fe-security-ws"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69.0"
    }
  }
}

