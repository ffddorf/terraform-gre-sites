data "netbox_device_interfaces" "lo" {
  filter {
    name  = "device_id"
    value = var.device_id
  }

  filter {
    name  = "name"
    value = "lo"
  }
}

data "netbox_device_interfaces" "eth1" {
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
  for_each = netbox_vlan.networks

  device_id = var.device_id
  name      = "${one(data.netbox_device_interfaces.eth1.interfaces).name}.${each.value.vid}"
  type      = "virtual"

  parent_device_interface_id = one(data.netbox_device_interfaces.eth1.interfaces).id

  description = each.value.name
}
