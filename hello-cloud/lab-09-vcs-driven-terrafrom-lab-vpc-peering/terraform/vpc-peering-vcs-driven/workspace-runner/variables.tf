variable "organization" {
  description = "HCP Terraform organization containing the target workspaces."
  type        = string
  default     = "minmyatko"
}

variable "workspace_names" {
  description = "Actual HCP workspace names, which may differ from local directory names."
  type = object({
    fe_network  = string
    fe_security = string
    fe_compute  = string
    be_network  = string
    be_security = string
    be_compute  = string
    peering     = string
  })

  default = {
    fe_network  = "fe-network-ws"
    fe_security = "fe-security-ws"
    fe_compute  = "fe-compute-ws"
    be_network  = "be-network-ws"
    be_security = "be-security-ws"
    be_compute  = "be-compute-ws"
    peering     = "vpc-peering"
  }
}