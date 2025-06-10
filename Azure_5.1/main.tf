terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  # Get base configuration for selected deployment size
  base_config = var.deployment_configs[var.deployment_size == "custom" ? "custom" : var.deployment_size]

  # Apply custom overrides if deployment_size is "custom"
  anvil_config = var.deployment_size == "custom" ? {
    configuration              = coalesce(var.custom_anvil_configuration, local.base_config.anvil.configuration)
    instance_type             = coalesce(var.custom_anvil_instance_type, local.base_config.anvil.instance_type)
    boot_disk_size_gb         = coalesce(var.custom_anvil_boot_disk_size_gb, local.base_config.anvil.boot_disk_size_gb)
    boot_disk_storage_type    = local.base_config.anvil.boot_disk_storage_type
    metadata_disk_size_gb     = coalesce(var.custom_anvil_metadata_disk_size_gb, local.base_config.anvil.metadata_disk_size_gb)
    metadata_disk_storage_type = local.base_config.anvil.metadata_disk_storage_type
  } : local.base_config.anvil

  dsx_config = var.deployment_size == "custom" ? {
    instance_count         = coalesce(var.custom_dsx_instance_count, local.base_config.dsx.instance_count)
    instance_type          = coalesce(var.custom_dsx_instance_type, local.base_config.dsx.instance_type)
    boot_disk_size_gb      = coalesce(var.custom_dsx_boot_disk_size_gb, local.base_config.dsx.boot_disk_size_gb)
    boot_disk_storage_type = local.base_config.dsx.boot_disk_storage_type
    data_disk_count        = coalesce(var.custom_dsx_data_disk_count, local.base_config.dsx.data_disk_count)
    data_disk_size_gb      = coalesce(var.custom_dsx_data_disk_size_gb, local.base_config.dsx.data_disk_size_gb)
    data_disk_storage_type = local.base_config.dsx.data_disk_storage_type
    data_disk_striping     = coalesce(var.custom_dsx_data_disk_striping, local.base_config.dsx.data_disk_striping)
  } : local.base_config.dsx
}

resource "azurerm_resource_group" "hammerspace_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.resource_tags, {
    DeploymentSize = var.deployment_size
  })
}

resource "azurerm_resource_group_template_deployment" "hammerspace_deployment" {
  name                = "${var.deployment_name_prefix}-arm-deployment"
  resource_group_name = azurerm_resource_group.hammerspace_rg.name
  deployment_mode     = "Incremental"

  template_content = file("${path.module}/hammerspace_template.json")

  parameters_content = jsonencode({
    location                       = { value = var.location }
    name                           = { value = var.deployment_name_prefix }
    solutionDeploymentType         = { value = var.solution_deployment_type }
    adminPassword                  = { value = var.admin_password }
    anvilConfiguration             = { value = local.anvil_config.configuration }
    anvilInstanceType              = { value = local.anvil_config.instance_type }
    anvilBootDiskStorageType       = { value = local.anvil_config.boot_disk_storage_type }
    anvilBootDiskSize              = { value = local.anvil_config.boot_disk_size_gb }
    anvilMetadataDiskStorageType   = { value = local.anvil_config.metadata_disk_storage_type }
    anvilMetadataDiskSize          = { value = local.anvil_config.metadata_disk_size_gb }
    DSXInstanceCount               = { value = local.dsx_config.instance_count }
    DSXInstanceType                = { value = local.dsx_config.instance_type }
    DSXBootDiskStorageType         = { value = local.dsx_config.boot_disk_storage_type }
    DSXBootDiskSize                = { value = local.dsx_config.boot_disk_size_gb }
    DSXDataDiskStorageType         = { value = local.dsx_config.data_disk_storage_type }
    DSXDataDiskCount               = { value = local.dsx_config.data_disk_count }
    DSXDataDiskSize                = { value = local.dsx_config.data_disk_size_gb }
    DSXDataDiskStriping            = { value = local.dsx_config.data_disk_striping }
    
    # Network parameters now point to existing resources
    virtualNetworkNewOrExisting    = { value = "existing" }
    virtualNetworkName             = { value = azurerm_virtual_network.hammerspace_vnet.name }
    virtualNetworkResourceGroup    = { value = azurerm_resource_group.hammerspace_rg.name }
    dataSubnetName                 = { value = azurerm_subnet.data_subnet.name }
    anvilDataClusterIP             = { value = var.anvil_data_cluster_ip }
    HASubnetName                   = { value = local.anvil_config.configuration == "High Availability" ? azurerm_subnet.ha_subnet[0].name : "" }
    networkSecurityGroupName       = { value = azurerm_network_security_group.hammerspace_nsg.name }
    availabilityZone               = { value = var.availability_zone }

    publicIPAddresses              = { value = var.public_ip_addresses_enabled }
    useProximityPlacementGroup     = { value = var.use_proximity_placement_group }
    proximityPlacementGroupName    = { value = var.proximity_placement_group_name }
    availabilitySetName            = { value = var.availability_set_name }
    tags                           = { value = jsonencode(merge(var.resource_tags, { DeploymentSize = var.deployment_size })) }
  })

  depends_on = [
    azurerm_resource_group.hammerspace_rg,
    azurerm_virtual_network.hammerspace_vnet,
    azurerm_subnet.data_subnet,
    azurerm_subnet_network_security_group_association.data_subnet_nsg_assoc,
  ]
}

# Outputs
output "deployment_configuration" {
  description = "Deployed configuration details"
  value = {
    deployment_size = var.deployment_size
    anvil_config    = local.anvil_config
    dsx_config      = local.dsx_config
  }
}