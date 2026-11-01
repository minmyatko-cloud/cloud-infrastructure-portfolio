terraform {
  required_version = "~>1.16.6"

  cloud {

    organization = "minmyatko"

    workspaces {
      name = "be-security-ws"
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

