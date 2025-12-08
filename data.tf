data "netbox_prefix" "sites_prefix_v4" {
  prefix = var.sites_prefix_v4
}

data "netbox_prefix" "sites_prefix_v6" {
  prefix = var.sites_prefix_v6
}

data "netbox_prefix" "tunnels_prefix_v4" {
  prefix = var.tunnels_prefix_v4
}

data "netbox_prefix" "tunnels_prefix_v6" {
  prefix = var.tunnels_prefix_v6
}

data "netbox_device_role" "device_role" {
  name = var.device_role
}

data "netbox_devices" "managed" {
  filter {
    name  = "tags"
    value = var.device_tag
  }
  filter {
    name  = "role_id"
    value = data.netbox_device_role.device_role.id
  }
}

data "netbox_tag" "core_router" {
  name = var.core_router_tag
}

data "netbox_devices" "core_routers" {
  filter {
    name  = "tags"
    value = var.core_router_tag
  }

  filter {
    name  = "status"
    value = "active"
  }
}

data "netbox_virtual_machines" "core_routers" {
  name_regex = "CR\\d+"

  # TODO: not implemented
  # filter {
  #   name  = "status"
  #   value = "active"
  # }
}

data "netbox_ipam_role" "transfer" {
  name = "Transfer"
}

locals {
  managed_devices = {
    for dev in data.netbox_devices.managed.devices : dev.name => dev
  }
  core_devices_unsorted = merge(
    { for dev in data.netbox_devices.core_routers.devices : dev.name => {
      id        = dev.device_id
      name      = dev.name
      device    = dev
      site_id   = dev.site_id
      tenant_id = dev.tenant_id
    } },
    { for vm in data.netbox_virtual_machines.core_routers.vms : vm.name => {
      id        = vm.vm_id
      name      = vm.name
      vm        = vm
      site_id   = vm.site_id
      tenant_id = vm.tenant_id
    } },
  )
  core_device_names_sorted = sort(keys(local.core_devices_unsorted))
  core_devices             = [for name in local.core_device_names_sorted : local.core_devices_unsorted[name]]
  core_tunnels = [for dev in local.core_devices : {
    name            = dev.name
    device_id       = dev.id
    device_type     = can(dev.vm) ? "vm" : "device"
    primary_ipv4_id = one(data.netbox_ip_addresses.core_primary[dev.name].ip_addresses).id
    site_id         = dev.site_id
    tenant_id       = dev.tenant_id
  }]
}

data "netbox_ip_addresses" "core_primary" {
  for_each = { for dev in local.core_devices : dev.name => dev }

  filter {
    name  = "ip_address"
    value = can(each.value.vm) ? each.value.vm.primary_ip4 : each.value.device.primary_ipv4
  }
}

data "netbox_asn" "ffddorf" {
  asn = 207871
}
