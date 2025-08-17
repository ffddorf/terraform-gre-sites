data "netbox_device_interfaces" "wan" {
  count = var.use_dnat_for_gre ? 1 : 0

  filter {
    name  = "device_id"
    value = var.device_id
  }

  filter {
    name  = "name"
    value = var.wan_interface
  }
}

resource "netbox_ip_address" "gre_dnat" {
  count = var.use_dnat_for_gre ? 1 : 0

  vrf_id              = one(netbox_vrf.local).id
  ip_address          = var.gre_dnat_ip
  status              = "active"
  device_interface_id = one(data.netbox_device_interfaces.wan[0].interfaces).id

  description = "Static Uplink IP (for GRE forwarding) on ${local.location}"
}
