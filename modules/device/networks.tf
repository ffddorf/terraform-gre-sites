resource "netbox_vrf" "local" {
  count = var.allocate_local_net || var.use_dnat_for_gre ? 1 : 0

  name = var.name

  tenant_id = var.tenant_id
}

resource "netbox_prefix" "local_v4" {
  count = var.allocate_local_net ? 1 : 0

  vrf_id = one(netbox_vrf.local).id
  prefix = var.client_prefix_v4
  status = "container"

  description = "Local network for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}

resource "netbox_prefix" "networks_v4" {
  for_each = var.allocate_local_net ? netbox_vlan.networks : {}

  vrf_id  = one(netbox_vrf.local).id
  vlan_id = each.value.id
  prefix  = cidrsubnet(one(netbox_prefix.local_v4).prefix, 8, each.value.vid)

  status      = "active"
  description = "'${each.value.name}' network for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}

resource "netbox_prefix" "networks_v6" {
  for_each = var.allocate_local_net ? netbox_vlan.networks : {}

  vlan_id = each.value.id
  prefix  = cidrsubnet(netbox_available_prefix.site_v6.prefix, 8, each.value.vid)

  status      = "active"
  description = "'${each.value.name}' network for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}
