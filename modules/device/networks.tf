resource "netbox_vrf" "local" {
  name = var.name
}

resource "netbox_prefix" "local_v4" {
  vrf_id = netbox_vrf.local.id
  prefix = var.client_prefix_v4
  status = "active"

  description = "Local network for ${var.name}"
}

resource "netbox_prefix" "networks_v4" {
  for_each = netbox_vlan.networks

  vrf_id  = netbox_vrf.local.id
  vlan_id = each.value.id
  prefix  = cidrsubnet(var.client_prefix_v4, 8, each.value.vid)

  status      = "active"
  description = "'${each.value.name}' network for ${var.name}"
}

resource "netbox_prefix" "networks_v6" {
  for_each = netbox_vlan.networks

  vlan_id = each.value.id
  prefix  = cidrsubnet(netbox_available_prefix.site_v6.prefix, 8, each.value.vid)

  status      = "active"
  description = "'${each.value.name}' network for ${var.name}"
}
