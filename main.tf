resource "netbox_vpn_tunnel_group" "sites" {
  name = "site-tunnels"
}

module "device" {
  for_each = local.managed_devices

  source = "./modules/device"

  site_id   = each.value.site_id
  device_id = each.value.device_id
  name      = each.value.name
  tenant_id = var.tenant_id

  allocate_local_net = true
  use_dnat_for_gre   = true

  sites_prefix_v4_id = data.netbox_prefix.sites_prefix_v4.id
  sites_prefix_v6_id = data.netbox_prefix.sites_prefix_v6.id

  tunnel_prefix_v4_id = data.netbox_prefix.tunnels_prefix_v4.id
  tunnel_vrf_v4_id    = data.netbox_prefix.tunnels_prefix_v4.vrf_id
  tunnel_prefix_v6_id = data.netbox_prefix.tunnels_prefix_v6.id
  tunnel_vrf_v6_id    = data.netbox_prefix.tunnels_prefix_v6.vrf_id

  core_tunnels = local.core_tunnels

  tunnel_prefix_role_id = data.netbox_ipam_role.transfer.id

  tunnel_group_id = netbox_vpn_tunnel_group.sites.id
}
