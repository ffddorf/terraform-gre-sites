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
