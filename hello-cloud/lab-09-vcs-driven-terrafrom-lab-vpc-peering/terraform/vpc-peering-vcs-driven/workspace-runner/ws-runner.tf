# 1. Frontend Network
resource "tfe_workspace_run" "fe_network" {
  workspace_id = data.tfe_workspace.target["fe_network"].id

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Frontend Network"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Frontend Network"
  }
}

# 2. Frontend Security
resource "tfe_workspace_run" "fe_security" {
  workspace_id = data.tfe_workspace.target["fe_security"].id
  depends_on = [tfe_workspace_run.fe_network]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Frontend Security"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Frontend Security"
  }
}

# 3. Frontend Compute
resource "tfe_workspace_run" "fe_compute" {
  workspace_id = data.tfe_workspace.target["fe_compute"].id

  depends_on = [tfe_workspace_run.fe_security]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Frontend Compute"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Frontend Compute"
  }
}

# 4. Backend Network
resource "tfe_workspace_run" "be_network" {
  workspace_id = data.tfe_workspace.target["be_network"].id

  depends_on = [tfe_workspace_run.fe_compute]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Backend Network"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Backend Network"
  }
}

# 5. Backend Security
resource "tfe_workspace_run" "be_security" {
  workspace_id = data.tfe_workspace.target["be_security"].id

  depends_on = [tfe_workspace_run.be_network]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Backend Security"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Backend Security"
  }
}

# 6. Backend Compute
resource "tfe_workspace_run" "be_compute" {
  workspace_id = data.tfe_workspace.target["be_compute"].id

  depends_on = [tfe_workspace_run.be_security]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: Backend Compute"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: Backend Compute"
  }
}

# 7. VPC Peering
resource "tfe_workspace_run" "vpc_peering" {
  workspace_id = data.tfe_workspace.target["peering"].id

  depends_on = [tfe_workspace_run.be_compute]

  # apply {
  #   manual_confirm = false
  #   wait_for_run   = true
  #   message        = "Initial apply: VPC Peering"
  # }

  destroy {
    manual_confirm = false
    wait_for_run   = true
    message        = "Destroy: VPC Peering"
  }
}