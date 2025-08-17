data "netbox_tenant" "tenant" {
  slug = var.tenant
}

data "netbox_site" "site" {
  slug = var.site
}

data "netbox_device_role" "router" {
  name = "Router"
}

data "netbox_device_type" "router" {
  slug = "router"
}

resource "netbox_device" "router" {
  count = var.existing_router == null ? 1 : 0

  name           = var.device_name
  site_id        = data.netbox_site.site.id
  role_id        = data.netbox_device_role.router.id
  tenant_id      = data.netbox_tenant.tenant.id
  device_type_id = data.netbox_device_type.router.id
}

data "netbox_devices" "router" {
  count = var.existing_router != null ? 1 : 0

  filter {
    name  = "name"
    value = var.existing_router
  }

  limit = 1
}

locals {
  device    = var.existing_router == null ? netbox_device.router[0] : data.netbox_devices.router[0].devices[0]
  device_id = var.existing_router == null ? netbox_device.router[0].id : data.netbox_devices.router[0].devices[0].device_id
}

data "netbox_device_interfaces" "wan" {
  count = var.existing_router != null ? 1 : 0

  filter {
    name  = "device_id"
    value = local.device_id
  }

  filter {
    name  = "tag"
    value = "uplink"
  }

  limit = 1
}

locals {
  wan = one(flatten(data.netbox_device_interfaces.wan[*].interfaces))
}

data "netbox_ip_addresses" "wan_ip" {
  count = var.remote_ip == null ? 1 : 0

  filter {
    name  = "interface_id"
    value = local.wan.id
  }
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

  tunnel_endpoint_public_v4 = var.remote_ip == null ? data.netbox_ip_addresses.wan_ip[0].ip_addresses[0].ip_address : var.remote_ip

  sites_prefix_v4_id = var.sites_prefix_v4_id
  sites_prefix_v6_id = var.sites_prefix_v6_id

  tunnel_prefix_v4_id = var.tunnel_prefix_v4_id
  tunnel_vrf_v4_id    = var.tunnel_vrf_v4_id
  tunnel_prefix_v6_id = var.tunnel_prefix_v6_id
  tunnel_vrf_v6_id    = var.tunnel_vrf_v6_id

  core_tunnels = var.core_tunnels

  tunnel_prefix_role_id = var.tunnel_prefix_role_id

  tunnel_group_id = var.tunnel_group_id
}
