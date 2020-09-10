variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "rob"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "uksouth"
}

variable "number_of_vms" {
  description = "Number of VMs to provision"
  type        = number
  default     = 3
}

variable "admin_username" {
  description = "The admin username"
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password"
  default     = "Ymn$DJ5Igv#0U0d906HZ"
}

variable "address_space" {
  description = "VNET address space"
  default     = "10.4.0.0/16"
}

variable "subnet" {
  description = "Subnet address space"
  default     = "10.4.0.0/24"
}

variable "ipconfig" {
  description = "ipconfig"
  default     = "ipconfig"
}