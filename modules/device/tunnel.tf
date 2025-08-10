resource "netbox_device_interface" "tunnels" {
  for_each = { for i, peer in var.core_tunnels : peer.name => i }

  type        = "virtual"
  name        = "tun${each.value}"
  label       = "Tunnel ${each.key}"
  description = "Tunnel to ${each.key}"
  device_id   = var.device_id
}

resource "netbox_device_interface" "core" {
  for_each = { for peer in var.core_tunnels : peer.name => peer if peer.device_type == "device" }

  type        = "virtual"
  name        = each.value.if_name
  label       = "Tunnel ${var.name}"
  description = "Tunnel to ${local.location}"
  device_id   = each.value.device_id

  mtu = 1476
}

resource "netbox_interface" "core" {
  for_each = { for peer in var.core_tunnels : peer.name => peer if peer.device_type == "vm" }

  name               = each.value.if_name
  description        = "Tunnel to ${local.location}"
  virtual_machine_id = each.value.device_id

  mtu = 1476
}

locals {
  core_interfaces = merge(netbox_device_interface.core, netbox_interface.core)
}

resource "netbox_available_prefix" "tunnels_v4" {
  for_each = { for peer in var.core_tunnels : peer.name => {} }

  parent_prefix_id = var.tunnel_prefix_v4_id
  vrf_id           = var.tunnel_vrf_v4_id
  prefix_length    = 31

  status      = "active"
  description = "Tunnel from ${each.key} to ${local.location}"
  role_id     = var.tunnel_prefix_role_id
  tenant_id   = var.tenant_id
}

resource "netbox_ip_address" "remote_tunnel_address_v4" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  ip_address  = "${cidrhost(netbox_available_prefix.tunnels_v4[each.key].prefix, 0)}/${netbox_available_prefix.tunnels_v4[each.key].prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
  tenant_id   = var.tenant_id
  vrf_id      = var.tunnel_vrf_v4_id

  object_type  = each.value.device_type == "vm" ? "virtualization.vminterface" : "dcim.interface"
  interface_id = local.core_interfaces[each.key].id
}

resource "netbox_ip_address" "local_tunnel_address_v4" {
  for_each = netbox_available_prefix.tunnels_v4

  ip_address          = "${cidrhost(each.value.prefix, 1)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
  tenant_id           = var.tenant_id
  vrf_id              = var.tunnel_vrf_v4_id
}

resource "netbox_available_prefix" "tunnels_v6" {
  for_each = { for peer in var.core_tunnels : peer.name => {} }

  parent_prefix_id = var.tunnel_prefix_v6_id
  prefix_length    = 64

  status      = "active"
  description = "Tunnel from ${each.key} to ${local.location}"
  role_id     = var.tunnel_prefix_role_id
  tenant_id   = var.tenant_id
  vrf_id      = var.tunnel_vrf_v6_id
}

resource "netbox_ip_address" "remote_tunnel_address_v6" {
  for_each = { for peer in var.core_tunnels : peer.name => peer }

  ip_address  = "${cidrhost(netbox_available_prefix.tunnels_v6[each.key].prefix, 1)}/${netbox_available_prefix.tunnels_v6[each.key].prefix_length}"
  status      = "active"
  description = "Peer address of ${each.key} for ${var.name}"
  tenant_id   = var.tenant_id
  vrf_id      = var.tunnel_vrf_v6_id

  object_type  = each.value.device_type == "vm" ? "virtualization.vminterface" : "dcim.interface"
  interface_id = local.core_interfaces[each.key].id
}

resource "netbox_ip_address" "local_tunnel_address_v6" {
  for_each = netbox_available_prefix.tunnels_v6

  ip_address          = "${cidrhost(each.value.prefix, 2)}/${each.value.prefix_length}"
  device_interface_id = netbox_device_interface.tunnels[each.key].id
  status              = "active"
  description         = "Peer address of ${var.name} for ${each.key}"
  tenant_id           = var.tenant_id
  vrf_id              = var.tunnel_vrf_v6_id
}

resource "netbox_vpn_tunnel" "core" {
  for_each = { for peer in var.core_tunnels : peer.name => {} }

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

  device_interface_id   = netbox_device_interface.tunnels[each.key].id
  outside_ip_address_id = netbox_ip_address.gre_dnat.id
}

resource "netbox_vpn_tunnel_termination" "core_device" {
  for_each = { for peer in var.core_tunnels : peer.name => peer if peer.device_type == "device" }

  tunnel_id = netbox_vpn_tunnel.core[each.key].id
  role      = "peer"

  device_interface_id   = netbox_device_interface.core[each.key].id
  outside_ip_address_id = each.value.primary_ipv4_id
}

resource "netbox_vpn_tunnel_termination" "core_vm" {
  for_each = { for peer in var.core_tunnels : peer.name => peer if peer.device_type == "vm" }

  tunnel_id = netbox_vpn_tunnel.core[each.key].id
  role      = "peer"

  virtual_machine_interface_id = netbox_interface.core[each.key].id
  outside_ip_address_id        = each.value.primary_ipv4_id
}
