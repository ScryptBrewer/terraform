variable "name" {
  description = "Name of the DSX VM"
  type        = string
}

variable "datastore_id" {
  description = "ID of the datastore for the VM"
  type        = string
}

variable "resource_pool_id" {
  description = "ID of the resource pool for the VM"
  type        = string
}

variable "host_system_id" {
  description = "ID of the host system for the VM"
  type        = string
}

variable "folder" {
  description = "Path to the VM folder in vCenter"
  type        = string
}

variable "datacenter_id" {
  description = "ID of the datacenter for the VM"
  type        = string
}

variable "cpu_count" {
  description = "Number of CPUs for the DSX VM"
  type        = number
}

variable "memory_mb" {
  description = "Memory in MB for the DSX VM"
  type        = number
}

variable "boot_disk_gb" {
  description = "Size of the boot disk in GB"
  type        = number
}

variable "data_disk_gb" {
  description = "Size of the data disk in GB for DSX"
  type        = number
}

variable "network_ids" {
  description = "List of network IDs for the VM's network interfaces"
  type        = list(string)
}

variable "ovf_template" {
  description = "OVF template data source object (contains local_ovf_path and ovf_network_map)"
  type        = any # More specific object type could be used if all attributes are known
}

variable "guest_id" {
  description = "Guest ID for the VM"
  type        = string
}

variable "prefix" {
  description = "Prefix used for VM components, like disk labels"
  type        = string
}

variable "cluster_config" {
  description = "Cluster-wide configuration for Hammerspace"
  type = object({
    domain_name     = string
    dns_servers     = string // Will be wrapped in a list in jsonencode
    ntp_servers     = string // Will be wrapped in a list in jsonencode
    default_gateway = string
    admin_password  = string
    anvil_ip        = string // Anvil's IP/NETMASK for metadata configuration
  })
}

variable "node_config" {
  description = "Node-specific configuration for this DSX VM"
  type = object({
    hostname = string
    ip       = string // Expected as just IP, e.g., "10.0.0.6"
  })
}
