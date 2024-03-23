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

data "netbox_devices" "devices" {
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
