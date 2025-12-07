data "netbox_rir" "RFC6996" {
  name = "RFC6996"
}

resource "netbox_asn" "device" {
  count = var.use_ibgp ? 0 : 1

  asn    = 4200000000 + var.device_id
  rir_id = data.netbox_rir.RFC6996.id

  description = local.location
}

locals {
  device_as_id = var.use_ibgp ? var.isp_asn_id : one(netbox_asn.device).id
}

resource "netboxbgp_session" "core_v4" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  local_as  = var.isp_asn_id
  remote_as = local.device_as_id

  local_address  = netbox_ip_address.remote_tunnel_address_v4[each.key].id
  remote_address = netbox_ip_address.local_tunnel_address_v4[each.key].id

  device         = each.value.device_type == "device" ? each.value.device_id : null
  virtualmachine = each.value.device_type == "vm" ? each.value.device_id : null

  site   = each.value.site_id
  tenant = each.value.tenant_id

  name        = "${each.key}-${var.name}-v4"
  description = local.location
}

resource "netboxbgp_session" "core_v6" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  local_as  = var.isp_asn_id
  remote_as = local.device_as_id

  local_address  = netbox_ip_address.remote_tunnel_address_v6[each.key].id
  remote_address = netbox_ip_address.local_tunnel_address_v6[each.key].id

  device         = each.value.device_type == "device" ? each.value.device_id : null
  virtualmachine = each.value.device_type == "vm" ? each.value.device_id : null

  site   = each.value.site_id
  tenant = each.value.tenant_id

  name        = "${each.key}-${var.name}-v6"
  description = local.location
}

resource "netboxbgp_session" "device_v4" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  local_as  = local.device_as_id
  remote_as = var.isp_asn_id

  local_address  = netbox_ip_address.local_tunnel_address_v4[each.key].id
  remote_address = netbox_ip_address.remote_tunnel_address_v4[each.key].id

  device = var.device_id

  site   = var.site_id
  tenant = var.tenant_id

  name        = "${var.name}-${each.key}-v4"
  description = each.key
}

resource "netboxbgp_session" "device_v6" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  local_as  = local.device_as_id
  remote_as = var.isp_asn_id

  local_address  = netbox_ip_address.local_tunnel_address_v6[each.key].id
  remote_address = netbox_ip_address.remote_tunnel_address_v6[each.key].id

  device = var.device_id

  site   = var.site_id
  tenant = var.tenant_id

  name        = "${var.name}-${each.key}-v6"
  description = each.key
}
