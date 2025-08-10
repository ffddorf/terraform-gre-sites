resource "netbox_vpn_tunnel_group" "sites" {
  name = "site-tunnels"
}

module "tunnel_interfaces" {
  for_each = { for dev in local.core_devices : dev.name => dev }

  source = "./modules/available_interfaces"

  prefix      = "tun"
  device_id   = each.value.id
  device_type = can(each.value.vm) ? "vm" : "device"
  targets     = [for name, dev in local.devices : name]
}

module "device" {
  for_each = local.devices

  source = "./modules/device"

  site_id   = each.value.site_id
  device_id = each.value.device_id
  name      = each.value.name
  tenant_id = var.tenant_id

  sites_prefix_v4_id = data.netbox_prefix.sites_prefix_v4.id
  sites_prefix_v6_id = data.netbox_prefix.sites_prefix_v6.id

  tunnel_prefix_v4_id = data.netbox_prefix.tunnels_prefix_v4.id
  tunnel_vrf_v4_id    = data.netbox_prefix.tunnels_prefix_v4.vrf_id
  tunnel_prefix_v6_id = data.netbox_prefix.tunnels_prefix_v6.id
  tunnel_vrf_v6_id    = data.netbox_prefix.tunnels_prefix_v6.vrf_id

  core_tunnels = [for dev in local.core_devices : {
    name            = dev.name
    device_id       = dev.id
    device_type     = can(dev.vm) ? "vm" : "device"
    if_name         = module.tunnel_interfaces[dev.name].interface_names[each.key]
    primary_ipv4_id = one(data.netbox_ip_addresses.core_primary[dev.name].ip_addresses).id
  }]

  tunnel_prefix_role_id = data.netbox_ipam_role.transfer.id

  tunnel_group_id = netbox_vpn_tunnel_group.sites.id
}
