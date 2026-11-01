# #############################################################
# # Frontend region
# #############################################################
variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

# #############################################################
# # Frontend prefix Variables
# #############################################################

variable "frontend_prefix" {
  description = "The prefix for the frontend resources."
  default     = "frontend"
}

variable "frontend_environment" {
  description = "The environment for the frontend resources."
  default     = "security"
}

##############################################################
# Frontend Organizaiton Name and Workspace Name Variabless
##############################################################


variable "frontend_organization" {
  description = "The organization for the frontend resources."
  default     = "minmyatko"
}

variable "frontend_network_workspace" {
  description = "The workspace for the frontend network resources."
  default     = "fe-network-ws"
}

variable "frontend_security_workspace" {
  description = "The workspace for the frontend security resources."
  default     = "fe-security-ws"
}

variable "allow_ip_from_public_users" {
  description = "The workspace for the frontend security resources."
  default     = "161.142.142.210/32"
  #default     = "0.0.0.0/0"
}




