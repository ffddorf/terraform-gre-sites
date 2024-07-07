resource "netbox_device_interface" "tunnels" {
  for_each = { for i, name in var.tunnel_peer_names : name => i }

  type        = "virtual"
  name        = "tun${each.value}"
  label       = "Tunnel ${each.key}"
  description = "Tunnel to ${each.key}"
  device_id   = var.device_id
}

resource "netbox_available_prefix" "tunnels_v4" {
  for_each = toset(var.tunnel_peer_names)

  parent_prefix_id = var.tunnel_prefix_v4_id
  prefix_length    = 31

  status      = "active"
  description = "Tunnel from ${each.value} to ${var.name}"
  role_id     = var.tunnel_prefix_role_id
  tenant_id   = var.tenant_id
}

resource "netbox_ip_address" "remote_tunnel_address_v4" {
  for_each = netbox_available_prefix.tunnels_v4

  ip_address  = "${cidrhost(each.value.prefix, 0)}/${each.value.prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
  tenant_id   = var.tenant_id
}

resource "netbox_ip_address" "local_tunnel_address_v4" {
  for_each = netbox_available_prefix.tunnels_v4

  ip_address          = "${cidrhost(each.value.prefix, 1)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
  tenant_id           = var.tenant_id
}

resource "netbox_available_prefix" "tunnels_v6" {
  for_each = toset(var.tunnel_peer_names)

  parent_prefix_id = var.tunnel_prefix_v6_id
  prefix_length    = 64

  status      = "active"
  description = "Tunnel from ${each.value} to ${var.name}"
  role_id     = var.tunnel_prefix_role_id
  tenant_id   = var.tenant_id
}

resource "netbox_ip_address" "remote_tunnel_address_v6" {
  for_each = netbox_available_prefix.tunnels_v6

  ip_address  = "${cidrhost(each.value.prefix, 1)}/${each.value.prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
  tenant_id   = var.tenant_id
}

resource "netbox_ip_address" "local_tunnel_address_v6" {
  for_each = netbox_available_prefix.tunnels_v6

  ip_address          = "${cidrhost(each.value.prefix, 2)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
  tenant_id           = var.tenant_id
}

resource "netbox_vpn_tunnel" "core" {
  for_each = { for i, name in var.tunnel_peer_names : name => i }

  name          = "${each.key}-${var.name}"
  encapsulation = "gre"
  status        = "active"
  description   = "Site tunnel from ${each.key} to ${local.location}"

  tunnel_group_id = var.tunnel_group_id
}

resource "netbox_vpn_tunnel_termination" "site" {
  for_each = netbox_vpn_tunnel.core

  tunnel_id = each.value.id
  role      = "peer"

  device_interface_id = netbox_device_interface.tunnels[each.key].id
}
