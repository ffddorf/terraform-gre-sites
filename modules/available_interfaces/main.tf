variable "device_id" {
  type        = number
  description = "ID of the device to find interfaces for"
}

variable "device_type" {
  type        = string
  description = "Whether to look for interfaces on a device or vm"
  default     = "device"
  validation {
    condition     = contains(["device", "vm"], var.device_type)
    error_message = "Must be one of 'device' or 'vm'"
  }
}

variable "prefix" {
  type        = string
  description = "interface prefix to find the next descendant for"
}

variable "targets" {
  type        = list(string)
  description = "names of targets to create interfaces for"
}

data "netbox_device_interfaces" "existing" {
  count = var.device_type == "device" ? 1 : 0

  name_regex = "^${var.prefix}\\d+$"

  filter {
    name  = "device_id"
    value = var.device_id
  }
}

data "netbox_interfaces" "existing" {
  count = var.device_type == "vm" ? 1 : 0

  name_regex = "^${var.prefix}\\d+$"

  filter {
    name  = "vm_id"
    value = var.device_id
  }
}

locals {
  if_names = concat(
    [for dev in flatten(data.netbox_device_interfaces.existing[*].interfaces) : dev.name],
    [for dev in flatten(data.netbox_interfaces.existing[*].interfaces) : dev.name],
  )
  if_nums              = [for name in local.if_names : parseint(one(regex("^${var.prefix}(\\d+)$", name)), 10)]
  max_if_num           = max(local.if_nums...)
  current_targets_hash = sha1(join("-", var.targets))
}

resource "terraform_data" "targets_hash" {
  for_each = { for name in var.targets : name => {} }

  input = local.current_targets_hash
  lifecycle {
    ignore_changes = [input]
  }
}

locals {
  # targets that have been added in the current apply
  relevant_targets = [for name in var.targets : name if terraform_data.targets_hash[name].output == local.current_targets_hash]
  target_offsets   = { for i, name in local.relevant_targets : name => i }
}

resource "terraform_data" "ifnum" {
  for_each = { for name in var.targets : name => {} }

  input = local.max_if_num + 1 + try(local.target_offsets[each.key], 0)
  lifecycle {
    ignore_changes = [input]
  }
}

output "interface_names" {
  value = {
    for name, data in terraform_data.ifnum : name => "${var.prefix}${coalesce(data.output, "-unknown")}"
  }
}
