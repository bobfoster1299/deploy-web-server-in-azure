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
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  /*
  # SSH access
  security_rule {
    name                       = "Port22FromSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnet
    destination_address_prefix = "Any"
  }
  */

  # HTTP access from Rob PC
  security_rule {
    name                       = "Port80FromRobPC"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "146.200.28.185"
    destination_address_prefix = "Any"
  }
}


# PIP
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-udacity-project1"
}


# AVSet
resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-avset"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
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
  }
}


# VM - WILL ADD LOOP TO MAKE MULTIPLE OF THEM LATER
resource "azurerm_linux_virtual_machine" "main" {
  name                             = "${var.prefix}-vm1"
  location                         = azurerm_resource_group.main.location
  resource_group_name              = azurerm_resource_group.main.name
  network_interface_ids            = [azurerm_network_interface.main.id]
  size                             = "Standard_B1ls"
  admin_username                   = var.admin_username
  admin_password                   = var.admin_password
  delete_os_disk_on_termination    = "True"
  delete_data_disks_on_termination = "True"
  disable_password_authentication  = "False"
  availability_set_id              = azurerm_availability_set.main.id

  # virtual machine storage image reference
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # virtual machine storage os disk
  os_disk {
    name              = "${var.prefix}-osdisk"
    create_option     = "Empty"
    managed_disk_type = "Standard_LRS"
  }

  # virtual machine os profile
  #os_profile {
  #  computer_name  = "${var.prefix}-vm1"
  #  admin_username = var.admin_username
  #  admin_password = var.admin_password
  #}

  # virtual machine os profile linux config
  #os_profile_linux_config {
  #  disable_password_authentication = "False"
  #}

  
  #storage_data_disk {
  #  name              = "${var.prefix}-datadisk"
  #  create_option     = "Empty"
  #  managed_disk_type = "Standard_LRS"
  #}

}


# Data disk
resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-datadisk"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}


# Data disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  managed_disk_id    = azurerm_managed_disk.main.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun                = "0"
  caching            = "ReadWrite"
}


# NIC
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}
