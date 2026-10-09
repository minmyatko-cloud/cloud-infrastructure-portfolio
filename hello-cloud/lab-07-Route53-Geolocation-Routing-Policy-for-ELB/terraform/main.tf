provider "aws" {
  region  = "ap-southeast-1"
  profile = "terraform-cli-admin"

  default_tags {
    tags = {
      Project   = "lab-07-route53-geolocation-routing-policy"
      ManagedBy = "Terraform"
    }
  }
}
provider "aws" {
  alias   = "london"
  region  = "eu-west-2"
  profile = "terraform-cli-admin"

  default_tags {
    tags = {
      Project   = "lab-07-route53-geolocation-routing-policy"
      ManagedBy = "Terraform"
    }
  }
}
provider "aws" {
  alias   = "california"
  region  = "us-west-1"
  profile = "terraform-cli-admin"

  default_tags {
    tags = {
      Project   = "lab-07-route53-geolocation-routing-policy"
      ManagedBy = "Terraform"
    }
  }
}