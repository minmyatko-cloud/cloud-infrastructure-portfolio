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
# Frontend Organizaiton Name and Workspace Name Variables
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

variable "be_security_group_id" {
  description = "prviate_sg_02_id and private_sg_03_id from backend"
  default     = ["sg-0b0cbcd32c51b8c3d","sg-0e7284fc9e951e63f"]
}


