# #############################################################
# # backend region
# #############################################################
variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

# #############################################################
# # backend prefix Variables
# #############################################################

variable "backend_prefix" {
  description = "The prefix for the backend resources."
  default     = "backend"
}

variable "backend_environment" {
  description = "The environment for the backend resources."
  default     = "security"
}

##############################################################
# backend Organizaiton Name and Workspace Name Variables
##############################################################


variable "backend_organization" {
  description = "The organization for the backend resources."
  default     = "minmyatko"
}

variable "backend_network_workspace" {
  description = "The workspace for the backend network resources."
  default     = "be-network-ws"
}

variable "backend_security_workspace" {
  description = "The workspace for the backend security resources."
  default     = "be-security-ws"
}

