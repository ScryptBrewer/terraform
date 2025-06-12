resource "vsphere_virtual_machine" "dsx_node" {
  name             = var.name
  datastore_id     = var.datastore_id
  resource_pool_id = var.resource_pool_id
  host_system_id   = var.host_system_id
  folder           = var.folder
  num_cpus         = var.cpu_count
  memory           = var.memory_mb
  guest_id         = var.guest_id
  datacenter_id    = var.datacenter_id
  wait_for_guest_net_timeout = 0 // As seen in main_ha_org.tf

  dynamic "network_interface" {
    for_each = var.network_ids
    content {
      network_id = network_interface.value
    }
  }

  disk {
    label            = "${var.prefix}-disk1"
    thin_provisioned = true
    size             = var.boot_disk_gb
  }
  disk {
    label            = "${var.prefix}-disk2"
    thin_provisioned = true
    unit_number      = 1
    size             = var.data_disk_gb
  }

  ovf_deploy {
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    local_ovf_path       = var.ovf_template.local_ovf_path
    ovf_network_map      = var.ovf_template.ovf_network_map
  }

  extra_config = {
    "guestinfo.ovfEnv" = jsonencode({
      cluster = {
        domainname  = var.cluster_config.domain_name
        dns_servers = [var.cluster_config.dns_servers]
        ntp_servers = [var.cluster_config.ntp_servers]
        metadata = {
          ips = [split("/", var.cluster_config.anvil_ip)[0]] // Extracts IP from Anvil's "IP/NETMASK"
        }
        gateway = {
          ipv4_default = var.cluster_config.default_gateway
        }
        password = var.cluster_config.admin_password
      }
      node = {
        add_volumes = true
        features    = ["storage", "portal"]
        hostname    = var.node_config.hostname
        networks = {
          ens160 = {
            roles = ["data", "mgmt"]
            ips   = [var.node_config.ip] // Assumes var.node_config.ip is just the IP address
            dhcp  = false
          }
          ens192 = { # From example DSX structure
            roles = []
            dhcp  = false
          }
          ens224 = { # From example DSX structure
            roles = []
            dhcp  = false
          }
        }
      }
    })
  }
}