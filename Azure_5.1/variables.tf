# Azure Configuration Variables
variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "deployment_name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

# Deployment Size Selection - MATCHES AWS PATTERN
variable "deployment_size" {
  description = "Deployment size: starter, medium, large, or custom"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["starter", "medium", "large", "custom"], var.deployment_size)
    error_message = "Deployment size must be starter, medium, large, or custom."
  }
}

# Pre-defined deployment configurations - MATCHES AWS PATTERN
variable "deployment_configs" {
  description = "Pre-defined deployment configurations for Azure"
  type = map(object({
    anvil = object({
      configuration           = string
      instance_type          = string  # Must match ARM template allowed values
      boot_disk_size_gb      = number
      boot_disk_storage_type = string
      metadata_disk_size_gb  = number
      metadata_disk_storage_type = string
    })
    dsx = object({
      instance_count         = number
      instance_type          = string  # Must match ARM template allowed values
      boot_disk_size_gb      = number
      boot_disk_storage_type = string
      data_disk_count        = number
      data_disk_size_gb      = number
      data_disk_storage_type = string
      data_disk_striping     = string
    })
  }))
  
  default = {
    starter = {
      anvil = {
        configuration              = "Standalone"
        instance_type             = "Standard_D8s_v3"    
        boot_disk_size_gb         = 100
        boot_disk_storage_type    = "Premium_LRS"
        metadata_disk_size_gb     = 200
        metadata_disk_storage_type = "Premium_LRS"
      }
      dsx = {
        instance_count         = 2
        instance_type          = "Standard_D8s_v3"     
        boot_disk_size_gb      = 100
        boot_disk_storage_type = "Premium_LRS"
        data_disk_count        = 1
        data_disk_size_gb      = 200
        data_disk_storage_type = "Premium_LRS"
        data_disk_striping     = "Disable"
      }
    }
    medium = {
      anvil = {
        configuration              = "High Availability"
        instance_type             = "Standard_D16s_v3" 
        boot_disk_size_gb         = 100
        boot_disk_storage_type    = "Premium_LRS"
        metadata_disk_size_gb     = 200
        metadata_disk_storage_type = "Premium_LRS"
      }
      dsx = {
        instance_count         = 5
        instance_type          = "Standard_D16s_v3"
        boot_disk_size_gb      = 100
        boot_disk_storage_type = "Premium_LRS"
        data_disk_count        = 1
        data_disk_size_gb      = 200
        data_disk_storage_type = "Premium_LRS"
        data_disk_striping     = "Disable"
      }
    }
    large = {
      anvil = {
        configuration              = "High Availability"
        instance_type             = "Standard_M64s"
        boot_disk_size_gb         = 100
        boot_disk_storage_type    = "Premium_LRS"
        metadata_disk_size_gb     = 500
        metadata_disk_storage_type = "Premium_LRS"
      }
      dsx = {
        instance_count         = 13
        instance_type          = "Standard_M64s" 
        boot_disk_size_gb      = 100
        boot_disk_storage_type = "Premium_LRS"
        data_disk_count        = 8
        data_disk_size_gb      = 1024
        data_disk_storage_type = "Premium_LRS"
        data_disk_striping     = "Enable"
      }
    }
    custom = {
      anvil = {
        configuration              = "Standalone"
        instance_type             = "Standard_D8s_v3"   
        boot_disk_size_gb         = 100
        boot_disk_storage_type    = "Premium_LRS"
        metadata_disk_size_gb     = 200
        metadata_disk_storage_type = "Premium_LRS"
      }
      dsx = {
        instance_count         = 2
        instance_type          = "Standard_D8s_v3"      
        boot_disk_size_gb      = 100
        boot_disk_storage_type = "Premium_LRS"
        data_disk_count        = 1
        data_disk_size_gb      = 200
        data_disk_storage_type = "Premium_LRS"
        data_disk_striping     = "Disable"
      }
    }
  }
}

# Custom override variables (only used when deployment_size = "custom")
variable "custom_anvil_configuration" {
  description = "Custom Anvil configuration (used with deployment_size = custom)"
  type        = string
  default     = null
}

variable "custom_anvil_instance_type" {
  description = "Custom Anvil instance type (used with deployment_size = custom)"
  type        = string
  default     = null
}

variable "custom_anvil_boot_disk_size_gb" {
  description = "Custom Anvil boot disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_metadata_disk_size_gb" {
  description = "Custom Anvil metadata disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_instance_count" {
  description = "Custom DSX instance count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_instance_type" {
  description = "Custom DSX instance type (used with deployment_size = custom)"
  type        = string
  default     = null
}

variable "custom_dsx_boot_disk_size_gb" {
  description = "Custom DSX boot disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_data_disk_count" {
  description = "Custom DSX data disk count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_data_disk_size_gb" {
  description = "Custom DSX data disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_data_disk_striping" {
  description = "Custom DSX data disk striping (used with deployment_size = custom)"
  type        = string
  default     = null
}

# Network Configuration - MUST BE IN TFVARS
variable "virtual_network_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "data_subnet_cidr" {
  description = "CIDR block for the data subnet"
  type        = string
}

variable "ha_subnet_cidr" {
  description = "CIDR block for the HA subnet (used with High Availability)"
  type        = string
}

variable "availability_zone" {
  description = "Specific availability zone to deploy all resources (1, 2, or 3). Leave empty for no zone preference."
  type        = string
  default     = ""
  
  validation {
    condition     = var.availability_zone == "" || contains(["1", "2", "3"], var.availability_zone)
    error_message = "Availability zone must be 1, 2, 3, or empty string."
  }
}

# Optional Network Variables
variable "virtual_network_name" {
  description = "Name for the virtual network (optional)"
  type        = string
  default     = ""
}

variable "data_subnet_name" {
  description = "Name for the data subnet (optional)"
  type        = string
  default     = ""
}

variable "ha_subnet_name" {
  description = "Name for the HA subnet (optional)"
  type        = string
  default     = ""
}

variable "network_security_group_name" {
  description = "Name for the network security group (optional)"
  type        = string
  default     = ""
}

# Hammerspace Configuration
variable "admin_password" {
  description = "Admin password for Hammerspace"
  type        = string
  sensitive   = true
}

variable "solution_deployment_type" {
  description = "Solution deployment type"
  type        = string
  default     = "Create a new solution"
}

variable "anvil_data_cluster_ip" {
  description = "Anvil data cluster IP (optional)"
  type        = string
  default     = ""
}

variable "public_ip_addresses_enabled" {
  description = "Enable public IP addresses"
  type        = string
  default     = "Disable"
}

variable "use_proximity_placement_group" {
  description = "Use proximity placement group"
  type        = bool
  default     = false
}

variable "proximity_placement_group_name" {
  description = "Proximity placement group name"
  type        = string
  default     = ""
}

variable "availability_set_name" {
  description = "Availability set name"
  type        = string
  default     = ""
}

variable "resource_tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}