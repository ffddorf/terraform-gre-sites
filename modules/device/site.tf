data "netbox_site" "current" {
  id = var.site_id
}

locals {
  location = "${var.name} (${data.netbox_site.current.name})"
}

resource "netbox_available_prefix" "site_v4" {
  parent_prefix_id = var.sites_prefix_v4_id
  prefix_length    = 32

  status      = "active"
  description = "Site prefix for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}

resource "netbox_ip_address" "loopback_v4" {
  ip_address  = "${cidrhost(netbox_available_prefix.site_v4.prefix, 0)}/${netbox_available_prefix.site_v4.prefix_length}"
  status      = "active"
  description = "Loopback address for ${local.location}"

  device_interface_id = var.allocate_local_net ? one(data.netbox_device_interfaces.lo[0].interfaces).id : null
  tenant_id           = var.tenant_id
}

resource "netbox_device_primary_ip" "v4" {
  device_id          = var.device_id
  ip_address_id      = netbox_ip_address.loopback_v4.id
  ip_address_version = 4
}

resource "netbox_available_prefix" "site_v6" {
  parent_prefix_id = var.sites_prefix_v6_id
  prefix_length    = 56

  status      = "active"
  description = "Site prefix for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}

locals {
  loopback_prefix_length  = 64
  loopback_prefix_newbits = local.loopback_prefix_length - netbox_available_prefix.site_v6.prefix_length
}

resource "netbox_prefix" "loopback_v6" {
  prefix      = cidrsubnet(netbox_available_prefix.site_v6.prefix, local.loopback_prefix_newbits, 0)
  status      = "active"
  description = "Loopback prefix for ${local.location}"
  tenant_id   = var.tenant_id
  site_id     = var.site_id
}

resource "netbox_ip_address" "loopback_v6" {
  ip_address  = "${cidrhost(netbox_prefix.loopback_v6.prefix, 1)}/${local.loopback_prefix_length}"
  status      = "active"
  description = "Loopback address for ${local.location}"

  device_interface_id = var.allocate_local_net ? one(data.netbox_device_interfaces.lo[0].interfaces).id : null
  tenant_id           = var.tenant_id
}

resource "netbox_device_primary_ip" "v6" {
  device_id          = var.device_id
  ip_address_id      = netbox_ip_address.loopback_v6.id
  ip_address_version = 6
}
