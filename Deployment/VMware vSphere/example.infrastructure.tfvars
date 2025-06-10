# vCenter infrastructure description
vsphere-server   = "vcenter.example.com"
vsphere-user     = "user@vsphere.local"
vsphere-password = ""

vsphere-datacenter      = "example_datacenter"
vsphere-host            = "esxi-example-host01"
vsphere-template-folder = "/path/to/templates"
vsphere-cluster         = "example-cluster"
vsphere-resource-pool   = "example-resource-pool"

vm-datastore = "esxi-example-host01-disk01"

network-data1 = "VLAN01"
network-ha1   = "VLAN02"

ntp-servers     = "10.20.30.40"
dns-servers     = "10.20.30.41"
default-gateway = "10.20.10.1"

# Local variables
prefix               = "example-vm-prefix"
vm-folder            = "path/to/folder"
hammerspace-ova-url  = "https://example.server.com/hammerspace-1.2.3-456.ova"
hammerspace-ova-path = "./hammerspace-1.2.3-456.ova"

# Hammerspace Cluster variables
admin-password     = "" # Hammerspace cluster admin password
HA_anvil1-ip       = "10.20.30.45/24"
HA-anvil1-hostname = "example-anvil01"

HA_anvil2-ip       = "10.20.30.46/24"
HA-anvil2-hostname = "example-anvil02"

dsx-count = 3
dsx-ips = {
  "0" = "10.20.30.47/24",
  "1" = "10.20.30.48/24",
  "2" = "10.20.30.49/24"
}
DSX-cpu   = 4
DSX-mem   = 12288
vm-domain = "example.local"

cluster-name = "example-cluster-name"
cluster-ip   = "10.20.30.50"

# VM hardware variables
HA-anvil-cpu = 6
HA-anvil-mem = 12288
