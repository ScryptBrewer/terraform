# Copyright (C) 2016-2024 Hammerspace, Inc.
# NOTICE: This software is subject to the terms of use posted here:
# http://www.hammerspace.com/company/EULA and you may only use this
# software if you are an authorized user. Your use of this software
# may be monitored and any unauthorized access or use may result in
# administrative, civil or criminal actions against you, under
# applicable law.

provider "google-beta" {
  project = var.project_id
  zone    = var.zone
}

# Local variables for deployment configuration selection and networking
locals {
  # Selects the appropriate configuration map based on the deployment_size variable.
  # If 'custom' is selected, it uses coalesce to merge any custom-provided
  # variables with the 'custom' defaults.
  selected_config = var.deployment_size == "custom" ? {
    anvil = {
      instance_count = coalesce(var.custom_anvil_instance_count, var.deployment_configs["custom"].anvil.instance_count)
      machine_type   = coalesce(var.custom_anvil_machine_type, var.deployment_configs["custom"].anvil.machine_type)
      data_disk_type = coalesce(var.custom_anvil_data_disk_type, var.deployment_configs["custom"].anvil.data_disk_type)
      data_disk_size = coalesce(var.custom_anvil_data_disk_size, var.deployment_configs["custom"].anvil.data_disk_size)
    }
    dsx = {
      instance_count  = coalesce(var.custom_dsx_instance_count, var.deployment_configs["custom"].dsx.instance_count)
      instance_type   = coalesce(var.custom_dsx_instance_type, var.deployment_configs["custom"].dsx.instance_type)
      data_disk_count = coalesce(var.custom_dsx_data_disk_count, var.deployment_configs["custom"].dsx.data_disk_count)
      data_disk_size  = coalesce(var.custom_dsx_data_disk_size, var.deployment_configs["custom"].dsx.data_disk_size)
    }
  } : var.deployment_configs[var.deployment_size]

  # Final calculated values to be used by resources
  anvil_instance_count_val = local.selected_config.anvil.instance_count
  machine_type_val        = local.selected_config.anvil.machine_type
  data_disk_type_val      = local.selected_config.anvil.data_disk_type
  data_disk_size_val      = local.selected_config.anvil.data_disk_size
  dsx_instance_count_val  = local.selected_config.dsx.instance_count
  dsx_instance_type_val   = local.selected_config.dsx.instance_type
  dsx_data_disk_count_val = local.selected_config.dsx.data_disk_count
  dsx_data_disk_size_val  = local.selected_config.dsx.data_disk_size

  # Networking and existing logic
  network_interfaces_map = { for i, n in var.networks : n => {
    network      = n,
    sub_networks = element(var.sub_networks, i)
  } }
  first_network_interface = values(local.network_interfaces_map)[0]
  region                  = join("-", slice(split("-", var.zone), 0, 2))
  subnetwork_name         = element(split("/", local.first_network_interface.sub_networks), length(split("/", local.first_network_interface.sub_networks)) - 1)
  subnet_mask             = element(split("/", data.google_compute_subnetwork.selected_subnetwork.ip_cidr_range), 1)
  final_anvil_instance_count = var.create_new_solution ? local.anvil_instance_count_val : 0
}

# Grab the subnetwork information needed for creating alias and data/mgmt IPs
data "google_compute_subnetwork" "selected_subnetwork" {
  name    = local.subnetwork_name
  region  = local.region
  project = var.project_id
}

# Create an alias IP used for cluster IP
resource "google_compute_address" "hammerspace_mds_alias_ip" {
  name         = "${var.goog_cm_deployment_name}-alias-ip"
  region       = local.region
  project      = var.project_id
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.selected_subnetwork.self_link
}

# Create data/mgmt IPs in advance for cross-referencing
resource "google_compute_address" "hammerspace_mds_ip" {
  count        = local.final_anvil_instance_count
  name         = "${var.goog_cm_deployment_name}-mds${count.index}-ip"
  region       = local.region
  project      = var.project_id
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.selected_subnetwork.self_link
}

resource "google_compute_disk" "hammerspace_mds_boot_disk" {
  count   = local.final_anvil_instance_count
  name    = "${var.goog_cm_deployment_name}-mds${count.index}-boot-disk"
  image   = var.image
  size    = var.boot_disk_size
  zone    = var.zone
  type    = var.boot_disk_type
  project = var.project_id
  guest_os_features {
    type = "MULTI_IP_SUBNET"
  }
}

resource "google_compute_disk" "hammerspace_dsx_boot_disk" {
  count   = local.dsx_instance_count_val
  name    = "${var.goog_cm_deployment_name}-dsx${count.index}-boot-disk"
  image   = var.image
  size    = var.dsx_disk_size
  zone    = var.zone
  type    = var.boot_disk_type
  project = var.project_id
  guest_os_features {
    type = "MULTI_IP_SUBNET"
  }
}

resource "google_compute_instance" "hammerspace_mds" {
  count          = local.final_anvil_instance_count
  name           = local.final_anvil_instance_count > 1 ? "${var.goog_cm_deployment_name}-mds${count.index}" : "${var.goog_cm_deployment_name}-mds"
  can_ip_forward = true
  zone           = var.zone
  machine_type   = local.machine_type_val
  project        = var.project_id

  tags = [
    "${var.goog_cm_deployment_name}-deployment",
    "${var.goog_cm_deployment_name}-web-0"
  ]

  boot_disk {
    source            = google_compute_disk.hammerspace_mds_boot_disk[count.index].id
    auto_delete       = true
    kms_key_self_link = var.kms_key
  }

  attached_disk {
    device_name = local.final_anvil_instance_count > 1 ? "${var.goog_cm_deployment_name}-mds${count.index}-disk1" : "${var.goog_cm_deployment_name}-mds-disk1"
    source      = google_compute_disk.hammerspace_mds_disk1[count.index].id
  }

  network_interface {
    network    = local.first_network_interface.network
    subnetwork = local.first_network_interface.sub_networks
    network_ip = google_compute_address.hammerspace_mds_ip[count.index].address
    dynamic "alias_ip_range" {
      for_each = count.index == 1 ? [1] : []
      content {
        ip_cidr_range = "${google_compute_address.hammerspace_mds_alias_ip.address}/32"
      }
    }
  }

  metadata = {
    admin_user_password = var.admin_user_password
    provision = local.final_anvil_instance_count <= 1 ? jsonencode({
      node = {
        ha_mode  = "Standalone",
        features = ["metadata"],
        hostname = "${var.goog_cm_deployment_name}-mds",
        networks = {
          eth0 = {
            roles = ["data", "mgmt"]
          }
        }
      }
    }) : jsonencode({
      cluster = {
        password = var.admin_user_password
      },
      node_index = tostring(count.index),
      nodes = {
        "0" = {
          features = ["metadata"],
          hostname = "${var.goog_cm_deployment_name}-mds0",
          ha_mode  = "Secondary",
          networks = {
            eth0 = {
              roles       = ["data", "mgmt", "ha"],
              cluster_ips = ["${google_compute_address.hammerspace_mds_alias_ip.address}/${local.subnet_mask}"],
              ips         = ["${google_compute_address.hammerspace_mds_ip1.address}/${local.subnet_mask}"]
            }
          }
        },
        "1" = {
          features = ["metadata"],
          hostname = "${var.goog_cm_deployment_name}-mds1",
          ha_mode  = "Primary",
          networks = {
            eth0 = {
              roles       = ["data", "mgmt", "ha"],
              cluster_ips = ["${google_compute_address.hammerspace_mds_alias_ip.address}/${local.subnet_mask}"],
              ips         = ["${google_compute_address.hammerspace_mds_ip2.address}/${local.subnet_mask}"]
            }
          }
        }
      }
    })
    ATTACHED_DISKS           = "${var.goog_cm_deployment_name}-mds-disk1"
    google-monitoring-enable = var.enable_monitoring
    google-logging-enable    = var.enable_logging
  }
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/cloudkms",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  depends_on = [
    google_compute_address.hammerspace_mds_alias_ip,
    google_compute_address.hammerspace_mds_ip,
    google_compute_disk.hammerspace_mds_boot_disk,
    google_compute_disk.hammerspace_mds_disk1
  ]
}

resource "google_compute_disk" "hammerspace_mds_disk1" {
  count   = local.final_anvil_instance_count
  name    = local.final_anvil_instance_count > 1 ? "${var.goog_cm_deployment_name}-mds${count.index}-disk1" : "${var.goog_cm_deployment_name}-mds-disk1"
  size    = local.data_disk_size_val
  zone    = var.zone
  type    = local.data_disk_type_val
  project = var.project_id

  disk_encryption_key {
    kms_key_self_link = var.kms_key
  }
}

# Create multiple data disks for DSX servers
resource "google_compute_disk" "hammerspace_dsx_data_disks" {
  count   = local.dsx_instance_count_val * local.dsx_data_disk_count_val
  name    = "${var.goog_cm_deployment_name}-dsx${floor(count.index / local.dsx_data_disk_count_val)}-disk${(count.index % local.dsx_data_disk_count_val) + 1}"
  size    = local.dsx_data_disk_size_val
  zone    = var.zone
  type    = local.data_disk_type_val
  project = var.project_id

  disk_encryption_key {
    kms_key_self_link = var.kms_key
  }
}

resource "google_compute_instance" "hammerspace_dsx" {
  count          = local.dsx_instance_count_val
  name           = "${var.goog_cm_deployment_name}-dsx${count.index}"
  can_ip_forward = false
  zone           = var.zone
  machine_type   = local.dsx_instance_type_val
  project        = var.project_id

  tags = [
    "${var.goog_cm_deployment_name}-deployment",
    "${var.goog_cm_deployment_name}-web-dsx${count.index}"
  ]

  boot_disk {
    source            = google_compute_disk.hammerspace_dsx_boot_disk[count.index].id
    auto_delete       = true
    kms_key_self_link = var.kms_key
  }

  # Dynamic block to attach multiple data disks
  dynamic "attached_disk" {
    for_each = range(local.dsx_data_disk_count_val)
    content {
      device_name = "${var.goog_cm_deployment_name}-dsx${count.index}-disk${attached_disk.value + 1}"
      source      = google_compute_disk.hammerspace_dsx_data_disks[count.index * local.dsx_data_disk_count_val + attached_disk.value].id
    }
  }

  network_interface {
    network    = local.first_network_interface.network
    subnetwork = local.first_network_interface.sub_networks
  }

  metadata = {
    provision = jsonencode({
      cluster = {
        metadata = {
          ips = [local.final_anvil_instance_count < 1 ? var.internal_ip : local.final_anvil_instance_count == 1 ? google_compute_instance.hammerspace_mds[0].network_interface[0].network_ip : google_compute_address.hammerspace_mds_alias_ip.address]
        },
        password = var.admin_user_password
      },
      node = {
        features    = ["portal", "storage"],
        add_volumes = var.add_volumes_dsx,
        hostname    = "${var.goog_cm_deployment_name}-dsx${count.index}",
        networks = {
          eth0 = {
            roles = ["data", "mgmt"]
          }
        }
      }
    })
    # Generate comma-separated list of attached disk names
    ATTACHED_DISKS = local.dsx_data_disk_count_val > 0 ? join(",", [for i in range(local.dsx_data_disk_count_val) : "${var.goog_cm_deployment_name}-dsx${count.index}-disk${i + 1}"]) : ""
    google-monitoring-enable = var.enable_monitoring
    google-logging-enable    = var.enable_logging
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/cloudkms",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  depends_on = [
    google_compute_disk.hammerspace_dsx_boot_disk,
    google_compute_disk.hammerspace_dsx_data_disks,
    google_compute_instance.hammerspace_mds
  ]
}

