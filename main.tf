locals {
  devices = {
    for dev in data.netbox_devices.devices.devices : dev.name => dev
  }
  core_devices = concat(
    [for dev in data.netbox_devices.core_routers.devices : {
      id     = dev.device_id
      name   = dev.name
      device = dev
    }],
    [for vm in data.netbox_virtual_machines.core_routers.vms : {
      id   = vm.vm_id
      name = vm.name
      vm   = vm
    }],
  )
}

resource "netbox_vpn_tunnel_group" "sites" {
  name = "site-tunnels"
}

module "tunnel_interfaces" {
  for_each = { for dev in local.core_devices : dev.name => dev }

  source = "./modules/available_interfaces"

  prefix      = "tun"
  device_id   = each.value.id
  device_type = can(each.value.vm) ? "vm" : "device"
  targets     = [for name, dev in local.devices : name]
}

module "device" {
  for_each = local.devices

  source = "./modules/device"

  site_id   = each.value.site_id
  device_id = each.value.device_id
  name      = each.value.name
  tenant_id = var.tenant_id

  sites_prefix_v4_id = data.netbox_prefix.sites_prefix_v4.id
  sites_prefix_v6_id = data.netbox_prefix.sites_prefix_v6.id

  tunnel_prefix_v4_id = data.netbox_prefix.tunnels_prefix_v4.id
  tunnel_prefix_v6_id = data.netbox_prefix.tunnels_prefix_v6.id

  core_tunnels = [for dev in local.core_devices : {
    name        = dev.name
    device_id   = dev.id
    device_type = can(dev.vm) ? "vm" : "device"
    if_name     = module.tunnel_interfaces[dev.name].interface_names[each.key]
  }]

  tunnel_prefix_role_id = data.netbox_ipam_role.transfer.id

  tunnel_group_id = netbox_vpn_tunnel_group.sites.id
}
