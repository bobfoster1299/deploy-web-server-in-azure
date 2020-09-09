provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg5"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet1"
  address_space       = ["10.4.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.4.0.0/24"]
}


#NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  #security_rule {
  #  name                       = "test123"
  #  priority                   = 100
  #  direction                  = "Inbound"
  #  access                     = "Allow"
  #  protocol                   = "Tcp"
  #  source_port_range          = "*"
  #  destination_port_range     = "*"
  #  source_address_prefix      = "*"
  #  destination_address_prefix = "*"
  #}
}



resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NEED TO ASSOCIATE IP WITH NIC?
resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"

  #tags = {
  #  environment = "Production"
  #}
}




#SCALE SET - SHOULD BE AVAILABILITY SET!!!!
resource "azurerm_virtual_machine_scale_set" "main" {
  name                = "${var.prefix}-"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  #rolling_upgrade_policy {
  #  max_batch_instance_percent              = 20
  #  max_unhealthy_instance_percent          = 20
  #  max_unhealthy_upgraded_instance_percent = 5
  #  pause_time_between_batches              = "PT0S"
  #}

  # required when using rolling upgrade policy
  #health_probe_id = azurerm_lb_probe.example.id

  sku {
    name     = "Standard_B1ls"
    #tier     = "Standard"
    capacity = 3
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    #name              = ""
    #caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    #caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "${var.prefix}-"
    admin_username       = var.admin_username
    admin_password       = var.admin_password
  }

/*
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = file("~/.ssh/demo_key.pub")
    }
  */
  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.main.id
      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      #load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
  
  }






/*
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1ls"
  #admin_username                  = "adminuser"
  #admin_password                  = "P@ssw0rd1234!"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
*/




