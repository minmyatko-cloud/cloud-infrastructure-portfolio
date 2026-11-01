variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

variable "availability_zone" {
  description = "The region where the resources are created."
  default     = ["ap-southeast-1a","ap-southeast-1b","ap-southeast-1c"]
}

# #############################################################
# # backend VPC Variables
# #############################################################

variable "backend_vpc_address_space" {
  description = "The CIDR block for the backend VPC."
  default     = "192.168.0.0/16"
}

variable "backend_prefix" {
  description = "The prefix for the backend resources."
  default     = "backend"
}

variable "backend_environment" {
  description = "The environment for the backend resources."
  default     = "backend_env"
}

variable "backend_public_subnet_cidr" {
  description = "The CIDR block for the backend public subnets."
  default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "backend_private_subnet_cidr" {
  description = "The CIDR block for the backend private subnets."
  default     = ["192.168.253.0/24", "192.168.254.0/24", "192.168.255.0/24"]
}