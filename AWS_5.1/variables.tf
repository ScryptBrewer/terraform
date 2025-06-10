# Modifications to this file are not required unless you plan to update defaults
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "stack_name" {
  description = "Name for the CloudFormation stack."
  type        = string
  default     = "hammerspace-cf-stack"
}

variable "cloudformation_template_url" {
  description = "URL of the CloudFormation template."
  type        = string
  default     = "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/a858de46-94c0-4c58-8413-348435c234a2/d2f3c37fb3164c9fbe61be602d7ac3b6.template"
}

variable "deployment_type" {
  description = "Parameter for CloudFormation: Choose to deploy a new stack or add DSX nodes."
  type        = string
  default     = "Create a new Hammerspace solution"
}

# Deployment Size Selection - NEW APPROACH
variable "deployment_size" {
  description = "Deployment size: starter, medium, large, or custom"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["starter", "medium", "large", "custom"], var.deployment_size)
    error_message = "Deployment size must be starter, medium, large, or custom."
  }
}

# Pre-defined deployment configurations - MATCHES GCP PATTERN
variable "deployment_configs" {
  description = "Pre-defined deployment configurations for AWS"
  type = map(object({
    anvil = object({
      configuration      = string  
      instance_type      = string  
      meta_disk_size     = number  
    })
    dsx = object({
      instance_count     = number  
      instance_type      = string  
      data_disk_size     = number  
      add_volumes        = string  
    })
  }))
  
  default = {
    starter = {
      anvil = {
        configuration  = "Standalone"                    
        instance_type  = "r5a.xlarge (4 vCPUs, 32 GiB Mem)"  
        meta_disk_size = 200
      }
      dsx = {
        instance_count = 2                               
        instance_type  = "r5a.xlarge (4 vCPUs, 32 GiB Mem)" 
        data_disk_size = 200                             
        add_volumes    = "Yes"
      }
    }
    medium = {
      anvil = {
        configuration  = "High Availability"            
        instance_type  = "r5a.4xlarge (16 vCPUs, 128 GiB Mem)"  
        meta_disk_size = 200
      }
      dsx = {
        instance_count = 5                               
        instance_type  = "r5a.4xlarge (16 vCPUs, 128 GiB Mem)" 
        data_disk_size = 200                             
        add_volumes    = "Yes"
      }
    }
    large = {
      anvil = {
        configuration  = "High Availability"            
        instance_type  = "r6i.24xlarge (96 vCPUs, 768 GiB Mem)" 
        meta_disk_size = 500                             
      }
      dsx = {
        instance_count = 13                              
        instance_type  = "r6i.24xlarge (96 vCPUs, 768 GiB Mem)" 
        data_disk_size = 1024                           
        add_volumes    = "Yes"
      }
    }
    custom = {
      anvil = {
        configuration  = "Standalone"                    
        instance_type  = "m5.xlarge (4 vCPUs, 16 GiB Mem)"
        meta_disk_size = 200
      }
      dsx = {
        instance_count = 2                               
        instance_type  = "m5.2xlarge (8 vCPUs, 32 GiB Mem)"
        data_disk_size = 200
        add_volumes    = "Yes"
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

variable "custom_anvil_meta_disk_size" {
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

variable "custom_dsx_data_disk_size" {
  description = "Custom DSX data disk size (used with deployment_size = custom)"
  type        = number
  default     = null
}

variable "custom_dsx_add_volumes" {
  description = "Custom DSX add volumes setting (used with deployment_size = custom)"
  type        = string
  default     = null
}

# Network and Infrastructure Variables - MUST BE IN TFVARS
variable "vpc_id" {
  description = "Parameter for CloudFormation: VPC ID."
  type        = string
}

variable "az1" {
  description = "Parameter for CloudFormation: Availability Zone for Anvil."
  type        = string
}

variable "subnet_1_id" {
  description = "Parameter for CloudFormation: Data/Management Subnet ID."
  type        = string
}

variable "sec_ip_cidr" {
  description = "Parameter for CloudFormation: Security Group IP/CIDR."
  type        = string
}

# Optional Network Variables
variable "az2" {
  description = "Parameter for CloudFormation: Second AZ to use (optional)."
  type        = string
  default     = ""
}

variable "subnet_2_id" {
  description = "Parameter for CloudFormation: Second Subnet ID (optional)."
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "Parameter for CloudFormation: Route Table ID (optional)."
  type        = string
  default     = ""
}

variable "cluster_ip" {
  description = "Parameter for CloudFormation: Anvil Cluster IP (optional)."
  type        = string
  default     = ""
}

# Security and Access Variables
variable "profile_id" {
  description = "Parameter for CloudFormation: Instance Profile ID (optional)."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Parameter for CloudFormation: Admin KeyPair Name (optional)."
  type        = string
  default     = ""
}

variable "iam_user_access" {
  description = "Parameter for CloudFormation: Admin IAM Group Access."
  type        = string
  default     = "Disable"
}

variable "iam_admin_group_id" {
  description = "Parameter for CloudFormation: Admin IAM Group ID (optional)."
  type        = string
  default     = ""
}