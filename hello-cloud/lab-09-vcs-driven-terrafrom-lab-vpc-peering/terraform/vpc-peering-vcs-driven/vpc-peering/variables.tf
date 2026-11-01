variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

variable "frontend_prefix" {
  description = "The prefix for the frontend resources."
  default     = "frontend"
}

variable "frontend_environment" {
  description = "The environment for the frontend resources."
  default     = "fontend_env"
}

variable "organization" {
  description = "The organization of vpc-peering-project"
  default     = "minmyatko"
}

variable "frontend_network_workspace" {
  description = "The frontend network worksapce of vpc-peering-project"
  default     = "fe-network-ws"
}

variable "frontend_security_workspace" {
  description = "The frontend security worksapce of vpc-peering-project"
  default     = "fe-security-ws"
}

variable "frontend_compute_workspace" {
  description = "The frontend security worksapce of vpc-peering-project"
  default     = "fe-compute-ws"
}


variable "backend_network_workspace" {
  description = "The backend network worksapce of vpc-peering-project"
  default     = "be-network-ws"
}

variable "backend_security_workspace" {
  description = "The backend security worksapce of vpc-peering-project"
  default     = "be-security-ws"
}


variable "backend_compute_workspace" {
  description = "The backend security worksapce of vpc-peering-project"
  default     = "be-compute-ws"
}
