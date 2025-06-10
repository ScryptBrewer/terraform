# Copyright (C) 2016-2024 Hammerspace, Inc.
# NOTICE: This software is subject to the terms of use posted here:
# http://www.hammerspace.com/company/EULA and you may only use this
# software if you are an authorized user. Your use of this software
# may be monitored and any unauthorized access or use may result in
# administrative, civil or criminal actions against you, under
# applicable law.

output "management_url" {
  description = "Public IP address of the Hammerspace compute instance"
  value = var.create_new_solution ? (length(google_compute_instance.hammerspace_mds) > 0 ? "https://${google_compute_instance.hammerspace_mds[0].network_interface[0].network_ip}" : null) : "https://${var.internal_ip}"
}

output "admin_user" {
  description = "Admin username for Hammerspace"
  value       = "admin"
}

output "instance_self_link" {
  description = "Self-link for the Hammerspace compute instance"
  value       = var.create_new_solution ? (length(google_compute_instance.hammerspace_mds) > 0 ? google_compute_instance.hammerspace_mds[0].self_link : "") : ""
}

output "instance_zone" {
  description = "Zone for the Hammerspace compute instance"
  value       = var.create_new_solution ? (length(google_compute_instance.hammerspace_mds) > 0 ? google_compute_instance.hammerspace_mds[0].zone : null) : (length(google_compute_instance.hammerspace_dsx) > 0 ? google_compute_instance.hammerspace_dsx[0].zone : null)
}

output "instance_machine_type" {
  description = "Machine type for the Hammerspace compute instance"
  value       = var.create_new_solution ? (length(google_compute_instance.hammerspace_mds) > 0 ? google_compute_instance.hammerspace_mds[0].machine_type : null) : (length(google_compute_instance.hammerspace_dsx) > 0 ? google_compute_instance.hammerspace_dsx[0].machine_type : null)
}

output "hammerspace_mds_alias_ip" {
  description = "Hammerspace MDS Alias IP Address"
  value       = google_compute_address.hammerspace_mds_alias_ip.address
}

output "hammerspace_mds_ips" {
  description = "Hammerspace MDS IP Addresses"
  value       = google_compute_address.hammerspace_mds_ip[*].address
}

output "deployment_configuration" {
  description = "Current deployment configuration"
  value = {
    deployment_size = var.deployment_size # Assuming var.deployment_size is a defined input
    anvil = {
      instance_count = local.selected_config.anvil.instance_count
      machine_type   = local.selected_config.anvil.machine_type
      data_disk_size = local.selected_config.anvil.data_disk_size
      data_disk_type = local.selected_config.anvil.data_disk_type
    }
    dsx = {
      instance_count  = local.selected_config.dsx.instance_count 
      instance_type   = local.selected_config.dsx.instance_type
      data_disk_count = local.selected_config.dsx.data_disk_count
      data_disk_size  = local.selected_config.dsx.data_disk_size
    }
  }
}