data "netbox_device_interfaces" "wan" {
  filter {
    name  = "device_id"
    value = var.device_id
  }

  filter {
    name  = "name"
    value = "eth2"
  }
}

resource "netbox_ip_address" "gre_dnat" {
  vrf_id              = netbox_vrf.local.id
  ip_address          = var.gre_dnat_ip
  status              = "active"
  device_interface_id = one(data.netbox_device_interfaces.wan.interfaces).id

  description = "Static Uplink IP (for GRE forwarding) on ${local.location}"
}
