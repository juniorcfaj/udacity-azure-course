provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "udacity" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
    "name" = "Deploying a Web Server in Azure - Project 1"
  }
}

resource "azurerm_virtual_network" "udacity" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  tags = {
    "name" = "Project 1"
  }
}

resource "azurerm_subnet" "udacity" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.udacity.name
  virtual_network_name = azurerm_virtual_network.udacity.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "udacity" {
  name = "${var.prefix}-nsc"
  location = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name

  security_rule {
    name                       = "AllowOutbound"
    description                = "Allow to access from others"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "10.0.0.0/16"
  }

  security_rule {
    name                       = "DenyInternetAccess"
    description                = "Deny everybody from Internet"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.0.0.0/16"
  }
  tags = {
    "name" = "Project 1"
  }
}

resource "azurerm_public_ip" "udacity" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location
  allocation_method   = "Static"

  tags = {
    "name" = "Project 1"
  }
}
resource "azurerm_network_interface" "udacity" {
  count = var.vm_count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location

  ip_configuration {
    name                          = "${var.prefix}-nic-configuration"
    subnet_id                     = azurerm_subnet.udacity.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    "name" = "Project 1"
  }
}

resource "azurerm_lb" "udacity" {
  name = "${var.prefix}-uda-lb"
  location = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name

  frontend_ip_configuration {
    name = "load-balancer-front-end"
    public_ip_address_id = azurerm_public_ip.udacity.id
  }
}

resource "azurerm_lb_backend_address_pool" "udacity" {
  loadbalancer_id = azurerm_lb.udacity.id
  name = "${var.prefix}-association"
}

resource "azurerm_network_interface_security_group_association" "udacity" {
  depends_on = [
    azurerm_network_interface.udacity
  ]
  count = var.vm_count
  network_interface_id = azurerm_network_interface.udacity[count.index].id
  network_security_group_id = azurerm_network_security_group.udacity.id
}

resource "azurerm_availability_set" "udacity" {
  name = "${var.prefix}-available-set"
  location = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
}

resource "azurerm_linux_virtual_machine" "udacity" {
  count = var.vm_count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.udacity.name
  location                        = azurerm_resource_group.udacity.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.user
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [element(azurerm_network_interface.udacity.*.id, count.index)]
  availability_set_id = azurerm_availability_set.udacity.id

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

  tags = {
    "name" = "Project 1"
  }
}

resource "azurerm_managed_disk" "udacity" {
  count = var.vm_count
  name = "disk-${count.index}"
  location = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 10
  
  tags = {
    "name" = "Project 1"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "udacity" {
  count = var.vm_count
  managed_disk_id = azurerm_managed_disk.udacity.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.udacity.*.id[count.index]
  lun = 10 * count.index
  caching = "ReadWrite"
}