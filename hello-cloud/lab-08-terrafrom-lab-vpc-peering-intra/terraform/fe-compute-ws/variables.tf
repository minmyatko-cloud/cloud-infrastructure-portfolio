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


# variable "frontend_public_subnet_cidr" {
#   description = "The CIDR block for the frontend public subnets."
#   default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }

# variable "frontend_private_subnet_cidr" {
#   description = "The CIDR block for the frontend private subnets."
#   default     = ["10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24"]
# }

variable "fe_instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}

# #############################################################
# # Backend VPC Variables
# #############################################################

# variable "backend_vpc_address_space" {
#   description = "The CIDR block for the backend VPC."
#   default     = "192.168.0.0/16"
# }

# variable "backend_prefix" {
#   description = "The prefix for the backend resources."
#   default     = "backend"
# }

# variable "backend_environment" {
#   description = "The environment for the backend resources."
#   default     = "dev"
# }

# variable "backend_public_subnet_cidr" {
#   description = "The CIDR block for the backend public subnets."
#   default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
# }

# variable "backend_private_subnet_cidr" {
#   description = "The CIDR block for the backend private subnets."
#   default     = ["192.168.253.0/24", "192.168.254.0/24", "192.168.255.0/24"]
# }

# variable "be_instance_type" {
#   description = "Specifies the AWS instance type."
#   default     = "t2.micro"
# }

# #############################################################
# # App Variables
# #############################################################

# variable "fe_placeholder" {
#   default     = "placedog.net"
#   description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
# }

# variable "be_placeholder" {
#   default     = "placebear.com"
#   description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
# }

# variable "placeholder_id" {
#   default     = "2"
#   description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
# }

# variable "width" {
#   default     = "600"
#   description = "Image width in pixels."
# }

# variable "height" {
#   default     = "400"
#   description = "Image height in pixels."
# }
