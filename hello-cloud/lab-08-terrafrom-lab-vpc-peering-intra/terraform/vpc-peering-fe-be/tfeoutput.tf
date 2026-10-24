data "tfe_outputs" "fe_network_ws" {
  organization = var.organization
  workspace    = var.frontend_network_workspace
}

data "tfe_outputs" "be_network_ws" {
  organization = var.organization
  workspace    = var.backend_network_workspace
}

data "tfe_outputs" "fe_security_ws" {
  organization = var.organization
  workspace    = var.frontend_security_workspace
}


data "tfe_outputs" "be_security_ws" {
  organization = var.organization
  workspace    = var.backend_security_workspace
}
