terraform {
  required_version = "~>1.16.0"

  cloud {
    organization = "minmyatko"

    workspaces {
      name = "workspace-runner-ws"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.82.0"
    }
  }
}

provider "tfe" {
  hostname = "app.terraform.io"
}