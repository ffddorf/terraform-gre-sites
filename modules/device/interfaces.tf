data "netbox_device_interfaces" "lo" {
  filter {
    name  = "device_id"
    value = var.device_id
  }

  filter {
    name  = "name"
    value = "lo"
  }

  limit = 1

  lifecycle {
    postcondition {
      condition     = length(self.interfaces) == 1
      error_message = "Unable to find lo interface on device"
    }
  }
}

data "netbox_device_interfaces" "eth1" {
  count = var.allocate_local_net ? 1 : 0

  filter {
    name  = "device_id"
    value = var.device_id
  }

  filter {
    name  = "name"
    value = "eth1"
  }
}

resource "netbox_device_interface" "lan" {
  for_each = var.allocate_local_net ? { for net in var.networks : net.id => net } : {}

  device_id = var.device_id
  name      = "${one(data.netbox_device_interfaces.eth1[0].interfaces).name}.${each.key}"
  label     = each.value.name
  type      = "virtual"

  parent_device_interface_id = one(data.netbox_device_interfaces.eth1[0].interfaces).id

  description = each.value.name

  depends_on = [
    netbox_vlan.networks
  ]
}

resource "netbox_ip_address" "router_addresses_v4" {
  for_each = netbox_prefix.networks_v4

  vrf_id              = one(netbox_vrf.local).id
  ip_address          = "${cidrhost(each.value.prefix, 1)}/16"
  status              = "active"
  device_interface_id = netbox_device_interface.lan[each.key].id
  tenant_id           = var.tenant_id

  description = "Local router address for '${netbox_vlan.networks[each.key].name}' network on ${var.name}"
}

resource "netbox_ip_address" "router_addresses_v6" {
  for_each = netbox_prefix.networks_v6

  ip_address          = "${cidrhost(each.value.prefix, 1)}/64"
  status              = "active"
  device_interface_id = netbox_device_interface.lan[each.key].id
  tenant_id           = var.tenant_id

  description = "Local router address for '${netbox_vlan.networks[each.key].name}' network on ${var.name}"
}
