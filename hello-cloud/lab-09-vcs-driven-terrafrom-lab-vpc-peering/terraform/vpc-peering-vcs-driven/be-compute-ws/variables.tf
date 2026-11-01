variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

variable "availability_zone_1" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1a"
}

variable "availability_zone_2" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1b"
}

variable "availability_zone_3" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1b"
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


variable "backend_public_subnet_cidr" {
  description = "The CIDR block for the backend public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "backend_private_subnet_cidr" {
  description = "The CIDR block for the backend private subnets."
  default     = ["10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24"]
}

variable "be_instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}

