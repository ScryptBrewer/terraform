# vSphere Connection
variable "vsphere_user" {
  description = "vSphere admin user"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere admin password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter FQDN or IP"
  type        = string
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "vsphere_resource_pool" {
  description = "vSphere resource pool"
  type        = string
}

variable "vsphere_host" {
  description = "vSphere host"
  type        = string
}

# Deployment Size Configuration
variable "deployment_size" {
  description = "Deployment size: starter, medium, large, or custom" # Updated options
  type        = string
  default     = "medium"

  validation {
    condition     = contains(["starter", "medium", "large", "custom"], var.deployment_size) # Updated options
    error_message = "Deployment size must be starter, medium, large, or custom."
  }
}

variable "deployment_configs" {
  description = "Pre-defined deployment configurations for vSphere"
  type = map(object({
    anvil = object({
      instance_count = number # Added for potential future HA Anvil setups from root
      cpu            = number
      memory_mb      = number # Renamed for clarity (was memory)
      boot_disk_gb   = number # Renamed for clarity (was boot_disk)
      metadata_disk_gb = number # Renamed for clarity (was metadata_disk)
    })
    dsx = object({
      instance_count = number # Renamed for clarity (was count)
      cpu            = number
      memory_mb      = number # Renamed for clarity (was memory)
      boot_disk_gb   = number # Renamed for clarity (was boot_disk)
    })
  }))

  default = {
    starter = { # New "starter" size, analogous to GCP
      anvil = {
        instance_count = 1
        cpu            = 4     
        memory_mb      = 16384 
        boot_disk_gb   = 100   
        metadata_disk_gb = 512   
      }
      dsx = {
        instance_count = 1     
        cpu            = 4     
        memory_mb      = 16384 
        boot_disk_gb   = 100    
      }
    }
    medium = { 
      anvil = {
        instance_count = 1    
        cpu            = 16   
        memory_mb      = 65536 
        boot_disk_gb   = 200  
        metadata_disk_gb = 1024
      }
      dsx = {
        instance_count = 3    
        cpu            = 8    
        memory_mb      = 32768 
        boot_disk_gb   = 100  
      }
    }
    large = { 
      anvil = {
        instance_count = 2    
        cpu            = 48   
        memory_mb      = 98304 
        boot_disk_gb   = 300  
        metadata_disk_gb = 2048
      }
      dsx = {
        instance_count = 7   
        cpu            = 16   
        memory_mb      = 65536 
        boot_disk_gb   = 150 
      }
    }
    custom = { 
      anvil = {
        instance_count = 1    
        cpu            = 16   
        memory_mb      = 65536 
        boot_disk_gb   = 200  
        metadata_disk_gb = 1024 
      }
      dsx = {
        instance_count = 2    
        cpu            = 8    
        memory_mb      = 32768 
        boot_disk_gb   = 100  
      }
    }
  }
}

# Custom override variables for vSphere (only used when deployment_size = "custom")
variable "custom_anvil_instance_count" {
  description = "Custom Anvil instance count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_cpu" {
  description = "Custom Anvil CPU count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_memory_mb" {
  description = "Custom Anvil memory in MB (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_boot_disk_gb" {
  description = "Custom Anvil boot disk size in GB (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_metadata_disk_gb" {
  description = "Custom Anvil metadata disk size in GB (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_instance_count" {
  description = "Custom DSX instance count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_cpu" {
  description = "Custom DSX CPU count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_memory_mb" {
  description = "Custom DSX memory in MB (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_boot_disk_gb" {
  description = "Custom DSX boot disk size in GB (used with deployment_size = custom)"
  type        = number
  default     = null
}

# Network Configuration
variable "data_network_name" {
  description = "Data network name - must be specified in tfvars"
  type        = string
}

variable "mgmt_network_name" {
  description = "Management network name - must be specified in tfvars"
  type        = string
}

variable "ha_network_name" {
  description = "HA network name - must be specified in tfvars"
  type        = string
}

# Global VM Settings
variable "vm_domain" {
  description = "VM domain name"
  type        = string
}

variable "prefix" {
  description = "VM name prefix"
  type        = string
}

variable "vm_folder" {
  description = "VM folder path"
  type        = string
}

variable "vm_datastore" {
  description = "VM datastore name"
  type        = string
}

# Hammerspace Configuration
variable "hammerspace_ova_path" {
  description = "Path to Hammerspace OVA file"
  type        = string
}

variable "hammerspace_vm_guest_id" {
  description = "VM guest OS ID"
  type        = string
  default     = "rhel7_64Guest"
}

variable "dns_servers" {
  description = "DNS servers"
  type        = string # Keep as string if it's a comma-separated list, or change to list(string)
}

variable "ntp_servers" {
  description = "NTP servers"
  type        = string # Keep as string if it's a comma-separated list, or change to list(string)
  default     = "time.google.com"
}

variable "default_gateway" {
  description = "Default gateway"
  type        = string
}

variable "admin_password" {
  description = "Hammerspace admin password"
  type        = string
  sensitive   = true
}

# Anvil Configuration
variable "anvil_ip" {
  description = "Anvil IP/NETMASK"
  type        = string
}

variable "anvil_hostname" {
  description = "Anvil hostname"
  type        = string
}

# DSX Configuration
variable "dsx_ips" {
  description = "DSX IP addresses (list of IP/NETMASK strings)"
  type        = list(string)
}

variable "dsx_data_disk_gb" {
  description = "DSX data disk size in GB (per instance)"
  type        = number
  default     = 1024 # This was already present and fits the new model
}