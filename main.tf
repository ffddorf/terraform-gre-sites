locals {
  devices = {
    for dev in data.netbox_devices.devices.devices : dev.name => dev
  }
}

resource "netbox_vpn_tunnel_group" "sites" {
  name = "site-tunnels"
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
  tunnel_prefix_v6_id = data.netbox_prefix.tunnels_prefix_v6.id

  tunnel_peer_names = concat(
    [for dev in data.netbox_devices.core_routers.devices : dev.name],
    [for vm in data.netbox_virtual_machines.core_routers.vms : vm.name],
  )

  tunnel_prefix_role_id = data.netbox_ipam_role.transfer.id

  tunnel_group_id = netbox_vpn_tunnel_group.sites.id
}
