# terraform.tfvars
# Basic Configuration
project_id = "your-project-id"
zone       = "us-central1-a"

# Deployment Size Selection
deployment_size = "medium"  # Options: starter, medium, large, custom

# Hammerspace Configuration
goog_cm_deployment_name = "hammerspace-5-1-24-318"
admin_user_password     = "YourSecurePassword"
kms_key                 = ""

# Network Configuration
networks     = ["your-network"]
sub_networks = ["your-subnet"]

# Custom Configuration (only used when deployment_size = "custom")
# custom_anvil_instance_count = 3
# custom_anvil_machine_type   = "n1-standard-8"
# custom_anvil_data_disk_size = 300
# custom_dsx_instance_count   = 6
# custom_dsx_instance_type    = "n1-standard-16"
# custom_dsx_data_disk_count  = 2
# custom_dsx_data_disk_size   = 512

# Optional Overrides
create_new_solution = true
internal_ip         = ""
add_volumes_dsx     = true
enable_logging      = true
enable_monitoring   = true
enable_https        = false