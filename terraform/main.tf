provider "azurerm" {
  features {}
}


# RG
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}


# VNET
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["${var.address_space}"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}


# Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["${var.subnet}"]
}


# NSG
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}


# HTTP access from Rob PC
resource "azurerm_network_security_rule" "http" {
  name                        = "Port80FromRobPC"
  priority                    = 120
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "TCP"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "146.200.28.185/32"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}


# SSH access from Rob PC
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Port22FromRobPC"
  priority                    = 130
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "TCP"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "146.200.28.185/32"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}


# PIP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-udacity-project1"
}


# AVSet
resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
}


# LB
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-lbfrontend"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}


# Backend address pool
 resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backendpool"
}


# LB health probe
resource "azurerm_lb_probe" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-lbhealth"
  port                = 80
}


# LB rule
resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.prefix}-lbrule"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-lbfrontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.main.id
}


# VM - WILL ADD LOOP TO MAKE MULTIPLE OF THEM LATER
resource "azurerm_linux_virtual_machine" "main" {
  count                            = var.number_of_vms
  name                             = "${var.prefix}-vm-${count.index}"
  location                         = azurerm_resource_group.main.location
  resource_group_name              = azurerm_resource_group.main.name
  network_interface_ids            = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  size                             = "Standard_B1ls"
  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
  disable_password_authentication  = false
  availability_set_id              = azurerm_availability_set.main.id

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.prefix}-osdisk-${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}


# Data disk
resource "azurerm_managed_disk" "main" {
  count                = var.number_of_vms
  name                 = "${var.prefix}-datadisk-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}


# Data disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.number_of_vms
  managed_disk_id    = element(azurerm_managed_disk.main.*.id, count.index)
  virtual_machine_id = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  lun                = "0"
  caching            = "ReadWrite"
}


# NIC
resource "azurerm_network_interface" "main" {
  count               = var.number_of_vms
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Associate VM with backend pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.number_of_vms
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  #ip_configuration_name   = element(azurerm_network_interface.main.*.ip_configuration[0].name, count.index)
  ip_configuration_name   = "${var.prefix}-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}


# Associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "main" {
  count                         = var.number_of_vms
  network_interface_id          = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id     = azurerm_network_security_group.main.id
}