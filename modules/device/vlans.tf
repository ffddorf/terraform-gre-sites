resource "netbox_vlan_group" "group" {
  count = var.allocate_local_net ? 1 : 0

  name = var.name
  slug = replace(var.name, "[^a-zA-Z0-9-]+", "-")

  vid_ranges = [[1, 256]]

  scope_type = "dcim.site"
  scope_id   = var.site_id
}

resource "netbox_vlan" "networks" {
  for_each = var.allocate_local_net ? { for net in var.networks : net.id => net } : {}

  name     = each.value.name
  vid      = each.value.id
  group_id = one(netbox_vlan_group.group).id
  site_id  = var.site_id

  tenant_id = var.tenant_id
}
