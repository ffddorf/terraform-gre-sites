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
