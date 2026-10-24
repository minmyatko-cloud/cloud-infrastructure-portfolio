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

variable "fe_security_group_id" {
  description = "prviate_sg_02_id and private_sg_03_id from frontend"
  default     = ["sg-06a24fbb6e05047e3","sg-0ce38aa6f81839582"]
}
