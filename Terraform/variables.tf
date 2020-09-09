variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "rob"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus"
}

variable "admin_username" {
  description = "The admin username"
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password"
  default     = "P@ssw0rd1234!"
}