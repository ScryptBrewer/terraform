# Azure region for deployment
location = "eastus"

# Resource Group and Deployment Name
resource_group_name = "hammerspace-resourcegroup"
deployment_name_prefix = "hammerspace-prod"

# Deployment size - choose starter, medium, large, or custom
deployment_size = "medium"

# Required network configuration - MUST BE SPECIFIED
virtual_network_cidr = "10.0.0.0/16"
data_subnet_cidr = "10.0.1.0/24"
ha_subnet_cidr = "10.0.2.0/24"

# Hammerspace Configuration
admin_password = "YourSecurePassword123!"
solution_deployment_type = "Create a new solution"

# Optional network names (will use defaults if not specified)
# Zone constraint - specify 1, 2, or 3 to force single zone
availability_zone = "1"
# virtual_network_name = "custom-vnet-name"
# data_subnet_name = "custom-data-subnet"
# ha_subnet_name = "custom-ha-subnet"
# network_security_group_name = "custom-nsg"

# Optional configuration
# anvil_data_cluster_ip = ""
# public_ip_addresses_enabled = false
# use_proximity_placement_group = false

# Resource tags
resource_tags = {
  Environment = "Production"
  Project     = "Hammerspace"
  Owner       = "IT Team"
}

# Custom overrides (only used when deployment_size = "custom")
# custom_anvil_configuration = "High Availability"
# custom_anvil_instance_type = "Standard_D8s_v3"
# custom_anvil_metadata_disk_size_gb = 400
# custom_dsx_instance_count = 3
# custom_dsx_instance_type = "Standard_D8s_v3"
# custom_dsx_data_disk_size_gb = 500