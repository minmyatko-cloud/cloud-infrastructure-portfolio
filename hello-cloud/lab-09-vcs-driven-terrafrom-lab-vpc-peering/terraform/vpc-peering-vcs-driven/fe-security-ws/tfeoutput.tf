data "tfe_outputs" "fe_network_ws" {
  organization = var.frontend_organization
  workspace    = var.frontend_network_workspace
}

data "tfe_outputs" "fe_security_ws" {
  organization = var.frontend_organization
  workspace    = var.frontend_security_workspace
}
