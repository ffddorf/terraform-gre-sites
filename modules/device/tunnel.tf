resource "netbox_device_interface" "tunnels" {
  for_each = { for i, name in var.tunnel_peer_names : name => i }

  type        = "virtual"
  name        = "tun${each.value}"
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
}

resource "netbox_ip_address" "remote_tunnel_address_v4" {
  for_each = netbox_available_prefix.tunnels_v4

  ip_address  = "${cidrhost(each.value.prefix, 0)}/${each.value.prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
}

resource "netbox_ip_address" "local_tunnel_address_v4" {
  for_each = netbox_available_prefix.tunnels_v4

  ip_address          = "${cidrhost(each.value.prefix, 1)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
}

resource "netbox_available_prefix" "tunnels_v6" {
  for_each = toset(var.tunnel_peer_names)

  parent_prefix_id = var.tunnel_prefix_v6_id
  prefix_length    = 64

  status      = "active"
  description = "Tunnel from ${each.value} to ${var.name}"
  role_id     = var.tunnel_prefix_role_id
}

resource "netbox_ip_address" "remote_tunnel_address_v6" {
  for_each = netbox_available_prefix.tunnels_v6

  ip_address  = "${cidrhost(each.value.prefix, 1)}/${each.value.prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
}

resource "netbox_ip_address" "local_tunnel_address_v6" {
  for_each = netbox_available_prefix.tunnels_v6

  ip_address          = "${cidrhost(each.value.prefix, 2)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
}
