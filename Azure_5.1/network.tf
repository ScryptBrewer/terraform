resource "azurerm_network_security_group" "hammerspace_nsg" {
  name                = var.network_security_group_name != "" ? var.network_security_group_name : "${var.deployment_name_prefix}-nsg"
  location            = azurerm_resource_group.hammerspace_rg.location
  resource_group_name = azurerm_resource_group.hammerspace_rg.name
  tags                = merge(var.resource_tags, {
    DeploymentSize = var.deployment_size
  })

  security_rule {
    name                       = "AllowHammerspacePorts"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges = [
      "22", "80", "111", "123", "137-139", "161", "443", "445", "662",
      "2049", "2224", "3049", "4379", "4505", "4506", "5405", "7789",
      "7790", "8443", "9000-9009", "9093", "9094-9099", "9292",
      "9298-9299", "9399", "20048", "20491", "20492", "21064",
      "30048", "30049"
    ]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "hammerspace_vnet" {
  name                = var.virtual_network_name != "" ? var.virtual_network_name : "${var.deployment_name_prefix}-vnet"
  location            = azurerm_resource_group.hammerspace_rg.location
  resource_group_name = azurerm_resource_group.hammerspace_rg.name
  address_space       = [var.virtual_network_cidr]
  tags                = merge(var.resource_tags, {
    DeploymentSize = var.deployment_size
  })
}

resource "azurerm_subnet" "data_subnet" {
  name                 = var.data_subnet_name != "" ? var.data_subnet_name : "${var.deployment_name_prefix}-datasubnet"
  resource_group_name  = azurerm_resource_group.hammerspace_rg.name
  virtual_network_name = azurerm_virtual_network.hammerspace_vnet.name
  address_prefixes     = [var.data_subnet_cidr]
}

resource "azurerm_subnet" "ha_subnet" {
  # Only create if Anvil Configuration is High Availability
  count = local.anvil_config.configuration == "High Availability" ? 1 : 0

  name                 = var.ha_subnet_name != "" ? var.ha_subnet_name : "${var.deployment_name_prefix}-hasubnet"
  resource_group_name  = azurerm_resource_group.hammerspace_rg.name
  virtual_network_name = azurerm_virtual_network.hammerspace_vnet.name
  address_prefixes     = [var.ha_subnet_cidr]
}

resource "azurerm_subnet_network_security_group_association" "data_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.data_subnet.id
  network_security_group_id = azurerm_network_security_group.hammerspace_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "ha_subnet_nsg_assoc" {
  # Only create if Anvil Configuration is High Availability
  count = local.anvil_config.configuration == "High Availability" ? 1 : 0

  subnet_id                 = azurerm_subnet.ha_subnet[0].id
  network_security_group_id = azurerm_network_security_group.hammerspace_nsg.id
}