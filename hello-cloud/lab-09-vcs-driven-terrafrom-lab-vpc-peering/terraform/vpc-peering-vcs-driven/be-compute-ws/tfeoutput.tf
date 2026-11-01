data "tfe_outputs" "be_network_ws" {
  organization = var.backend_organization
  workspace    = var.backend_network_workspace
}

data "tfe_outputs" "be_security_ws" {
  organization = var.backend_organization
  workspace    = var.backend_security_workspace
}
