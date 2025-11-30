data "netbox_tenant" "tenant" {
  slug = var.tenant
}

data "netbox_site" "site" {
  slug = var.site
}

locals {
  device    = var.existing_router == null ? netbox_device.router[0] : data.netbox_devices.router[0].devices[0]
  device_id = var.existing_router == null ? netbox_device.router[0].id : data.netbox_devices.router[0].devices[0].device_id
}


module "tunnel" {
  source = "../device"

  site_id       = data.netbox_site.site.id
  device_id     = local.device_id
  name          = local.device.name
  tenant_id     = data.netbox_tenant.tenant.id
  wan_interface = var.existing_router == null ? "wan" : local.wan.name

  allocate_local_net = false
  use_dnat_for_gre   = false

  tunnel_endpoint_address_id = local.wan_ip_id

  sites_prefix_v4_id = var.sites_prefix_v4_id
  sites_prefix_v6_id = var.sites_prefix_v6_id

  tunnel_prefix_v4_id = var.tunnel_prefix_v4_id
  tunnel_vrf_v4_id    = var.tunnel_vrf_v4_id
  tunnel_prefix_v6_id = var.tunnel_prefix_v6_id
  tunnel_vrf_v6_id    = var.tunnel_vrf_v6_id

  core_tunnels = var.core_tunnels

  tunnel_prefix_role_id = var.tunnel_prefix_role_id

  tunnel_group_id = var.tunnel_group_id

  isp_asn_id = var.isp_asn_id
}
