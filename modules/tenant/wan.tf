data "netbox_device_interfaces" "wan_tagged" {
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

  lifecycle {
    postcondition {
      condition     = length(self.interfaces) == 1
      error_message = "When using an existing device, the WAN interface need to be tagged with the 'Uplink' tag"
    }
  }
}

data "netbox_device_interfaces" "wan_named" {
  count = var.existing_router == null ? 1 : 0

  filter {
    name  = "device_id"
    value = local.device_id
  }

  filter {
    name  = "name"
    value = "wan"
  }

  limit = 1
}

locals {
  wan = (
    var.existing_router != null
    ? one(flatten(data.netbox_device_interfaces.wan_tagged[*].interfaces))
    : one(flatten(data.netbox_device_interfaces.wan_named[*].interfaces))
  )
}

data "netbox_ip_addresses" "wan_ip" {
  count = var.remote_ip == null ? 1 : 0

  filter {
    name  = "interface_id"
    value = local.wan.id
  }

  lifecycle {
    postcondition {
      condition     = length([for a in self.ip_addresses : a if a.address_family == "IPv4"]) == 1
      error_message = "The wan interface needs to have exactly one IPv4 address assigned"
    }
  }
}

resource "netbox_ip_address" "wan" {
  count = var.remote_ip != null ? 1 : 0

  ip_address = var.remote_ip
  status     = "active"

  device_interface_id = local.wan.id
  tenant_id           = data.netbox_tenant.tenant.id

  description = "Tunnel endpoint for ${local.device.name}"
}

locals {
  wan_ip_id = (var.remote_ip != null
    ? netbox_ip_address.wan[0].id
    : [for a in data.netbox_ip_addresses.wan_ip[0].ip_addresses : a.id if a.address_family == "IPv4"][0]
  )
}
