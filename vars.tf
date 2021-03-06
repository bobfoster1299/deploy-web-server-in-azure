variable "prefix" {
  description = "The prefix which should be used for all resources in this deployment"
  default     = "rob"
}

variable "location" {
  description = "The azure region in which all resources in this deployment should be created."
  default     = "uksouth"
}

variable "number_of_vms" {
  description = "Number of VMs to provision"
  type        = number
  default     = 3
}

variable "admin_username" {
  description = "The admin username for the VMs"
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password for the VMs"
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

variable "environment" {
  description = "Environment tag, e.g. prod, dev"
  default     = "dev"
}

variable "project" {
  description = "Project tag"
  default     = "deploy-web-server-in-azure"
}

variable "owner" {
  description = "Owner tag"
  default     = "Rob Foster"
}

variable "image" {
  description = "The VM image to deploy"
  default     = "rob-packer-image"
}