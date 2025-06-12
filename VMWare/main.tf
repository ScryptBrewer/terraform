# main.tf
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"
    }
  }
}


provider "vsphere" {
  vim_keep_alive       = 30
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# Data sources
locals {
  base_config = var.deployment_configs[var.deployment_size == "custom" ? "custom" : var.deployment_size]

  anvil_config = var.deployment_size == "custom" ? {
    instance_count   = coalesce(var.custom_anvil_instance_count, local.base_config.anvil.instance_count)
    cpu              = coalesce(var.custom_anvil_cpu, local.base_config.anvil.cpu)
    memory_mb        = coalesce(var.custom_anvil_memory_mb, local.base_config.anvil.memory_mb)
    boot_disk_gb     = coalesce(var.custom_anvil_boot_disk_gb, local.base_config.anvil.boot_disk_gb)
    metadata_disk_gb = coalesce(var.custom_anvil_metadata_disk_gb, local.base_config.anvil.metadata_disk_gb)
  } : local.base_config.anvil

  dsx_config = var.deployment_size == "custom" ? {
    instance_count = coalesce(var.custom_dsx_instance_count, local.base_config.dsx.instance_count)
    cpu            = coalesce(var.custom_dsx_cpu, local.base_config.dsx.cpu)
    memory_mb      = coalesce(var.custom_dsx_memory_mb, local.base_config.dsx.memory_mb)
    boot_disk_gb   = coalesce(var.custom_dsx_boot_disk_gb, local.base_config.dsx.boot_disk_gb)
    # dsx_data_disk_gb is a separate variable, not part of this map
  } : local.base_config.dsx
}


data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "data_network" {
  name          = var.data_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "mgmt_network" {
  name          = var.mgmt_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "ha_network" {
  name          = var.ha_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# OVF Template
data "vsphere_ovf_vm_template" "hammerspace" {
  name             = "${var.prefix}-anvil-tmpl.${var.vm_domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  local_ovf_path   = var.hammerspace_ova_path

  ovf_network_map = {
    "VM Network"   = data.vsphere_network.data_network.id
    "VM Network 2" = data.vsphere_network.mgmt_network.id
    "VM Network 3" = data.vsphere_network.ha_network.id
  }
}

# Anvil VM
module "anvil" {
  source = "./modules/anvil"
  
  # VM Configuration
  name             = "${var.prefix}-anvil.${var.vm_domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm_folder
  datacenter_id    = data.vsphere_datacenter.dc.id
  
  # Hardware Configuration
  cpu_count        = local.anvil_config.cpu
  memory_mb        = local.anvil_config.memory_mb
  boot_disk_gb     = local.anvil_config.boot_disk_gb
  metadata_disk_gb = local.anvil_config.metadata_disk_gb
  
  # Network Configuration
  network_ids = [
    data.vsphere_network.data_network.id,
    data.vsphere_network.mgmt_network.id,
    data.vsphere_network.ha_network.id
  ]
  
  # OVF Configuration
  ovf_template = data.vsphere_ovf_vm_template.hammerspace
  
  # Hammerspace Configuration
  cluster_config = {
    domain_name     = var.vm_domain
    dns_servers     = var.dns_servers
    ntp_servers     = var.ntp_servers
    default_gateway = var.default_gateway
    admin_password  = var.admin_password
  }
  
  node_config = {
    hostname = "${var.prefix}-${var.anvil_hostname}"
    ip       = var.anvil_ip
  }
  
  guest_id = var.hammerspace_vm_guest_id
  prefix   = var.prefix
}

# DSX VMs
module "dsx" {
  source = "./modules/dsx"
  count  = local.deployment_config.dsx.count
  
  # VM Configuration
  name             = "${var.prefix}-dsx-${count.index + 1}.${var.vm_domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm_folder
  datacenter_id    = data.vsphere_datacenter.dc.id
  
  # Hardware Configuration
  cpu_count     = local.dsx_config.cpu
  memory_mb     = local.dsx_config.memory_mb
  boot_disk_gb  = local.dsx_config.boot_disk_gb
  data_disk_gb  = var.dsx_data_disk_gb
  
  # Network Configuration
  network_ids = [
    data.vsphere_network.data_network.id,
    data.vsphere_network.mgmt_network.id,
    data.vsphere_network.ha_network.id
  ]
  
  # OVF Configuration
  ovf_template = data.vsphere_ovf_vm_template.hammerspace
  
  # Hammerspace Configuration
  cluster_config = {
    domain_name     = var.vm_domain
    dns_servers     = var.dns_servers
    ntp_servers     = var.ntp_servers
    default_gateway = var.default_gateway
    admin_password  = var.admin_password
    anvil_ip        = var.anvil_ip
  }
  
  node_config = {
    hostname = "${var.prefix}-dsx-${count.index + 1}"
    ip       = var.dsx_ips[count.index]
  }
  
  guest_id = var.hammerspace_vm_guest_id
  prefix   = var.prefix
}