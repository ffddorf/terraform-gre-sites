resource "netbox_vlan_group" "group" {
  name = var.name
  slug = replace(var.name, "[^a-zA-Z0-9-]+", "-")

  min_vid = 1
  max_vid = 256

  scope_type = "dcim.site"
  scope_id   = var.site_id
}

resource "netbox_vlan" "networks" {
  for_each = { for net in var.networks : net.id => net }

  name     = each.value.name
  vid      = each.value.id
  group_id = netbox_vlan_group.group.id
  site_id  = var.site_id

  tenant_id = var.tenant_id
}
