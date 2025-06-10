# Copyright (C) 2016-2024 Hammerspace, Inc.
# NOTICE: This software is subject to the terms of use posted here:
# http://www.hammerspace.com/company/EULA and you may only use this
# software if you are an authorized user. Your use of this software
# may be monitored and any unauthorized access or use may result in
# administrative, civil or criminal actions against you, under
# applicable law.

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
}

# Deployment Size Selection
variable "deployment_size" {
  description = "Deployment size: starter, medium, large, or custom"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["starter", "medium", "large", "custom"], var.deployment_size)
    error_message = "Deployment size must be starter, medium, large, or custom."
  }
}

# Pre-defined deployment configurations
variable "deployment_configs" {
  description = "Pre-defined deployment configurations"
  type = map(object({
    anvil = object({
      instance_count = number
      machine_type   = string
      data_disk_type = string
      data_disk_size = number
    })
    dsx = object({
      instance_count     = number
      instance_type      = string
      data_disk_count    = number
      data_disk_size     = number
    })
  }))
  
  default = {
    starter = {
      anvil = {
        instance_count = 1
        machine_type   = "n1-standard-4"
        data_disk_type = "pd-standard"
        data_disk_size = 200
      }
      dsx = {
        instance_count  = 2
        instance_type   = "n1-standard-8"
        data_disk_count = 1
        data_disk_size  = 200
      }
    }
    medium = {
      anvil = {
        instance_count = 2
        machine_type   = "n1-standard-4"
        data_disk_type = "pd-standard"
        data_disk_size = 200
      }
      dsx = {
        instance_count  = 5
        instance_type   = "n1-standard-8"
        data_disk_count = 1
        data_disk_size  = 200
      }
    }
    large = {
      anvil = {
        instance_count = 2
        machine_type   = "n2-highmem-32"
        data_disk_type = "pd-extreme"
        data_disk_size = 500
      }
      dsx = {
        instance_count  = 13
        instance_type   = "n2-highmem-32"
        data_disk_count = 8
        data_disk_size  = 1024
      }
    }
    custom = {
      anvil = {
        instance_count = 1
        machine_type   = "n1-standard-4"
        data_disk_type = "pd-standard"
        data_disk_size = 200
      }
      dsx = {
        instance_count  = 2
        instance_type   = "n1-standard-8"
        data_disk_count = 1
        data_disk_size  = 200
      }
    }
  }
}

# Custom override variables (only used when deployment_size = "custom")
variable "custom_anvil_instance_count" {
  description = "Custom Anvil instance count (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_machine_type" {
  description = "Custom Anvil machine type (used with deployment_size = custom)"
  type        = string
  default     = null
}

variable "custom_anvil_data_disk_size" {
  description = "Custom Anvil data disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_anvil_data_disk_type" {
  description = "Custom Anvil data disk count per server (used with deployment_size = custom)"
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

variable "custom_dsx_data_disk_count" {
  description = "Custom DSX data disk count per server (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_data_disk_size" {
  description = "Custom DSX data disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

# Existing variables remain the same
variable "goog_cm_deployment_name" {
  description = "Deployment name"
  type        = string
  default     = "hammerspace-5-1-24-318"
}

variable "admin_user_password" {
  description = "Admin user password"
  type        = string
  sensitive   = true
}

variable "kms_key" {
  description = "KMS key for encryption"
  type        = string
  default     = ""
}

variable "networks" {
  description = "Network names"
  type        = list(string)
}

variable "sub_networks" {
  description = "Subnetwork names"
  type        = list(string)
}

variable "internal_ip" {
  description = "Internal IP for existing solutions"
  type        = string
  default     = ""
}

variable "create_new_solution" {
  description = "Create new solution"
  type        = bool
  default     = true
}

variable "image" {
  description = "Hammerspace image"
  type        = string
  default     = "projects/hammerspace-public/global/images/hammerspace-5-1-24-318"
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "boot_disk_size" {
  description = "Boot disk size"
  type        = number
  default     = 100
}

variable "dsx_disk_size" {
  description = "DSX boot disk size"
  type        = number
  default     = 100
}

variable "add_volumes_dsx" {
  description = "Add volumes to DSX"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS"
  type        = bool
  default     = false
}