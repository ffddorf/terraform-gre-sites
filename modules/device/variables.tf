variable "device_id" {
  type        = number
  description = "Netbox ID of the device"
}

variable "name" {
  type        = string
  description = "name of the device"
}

variable "sites_prefix_v4_id" {
  type        = number
  description = "Netbox ID of prefix (v4) to create site prefix in"
}

variable "sites_prefix_v6_id" {
  type        = number
  description = "Netbox ID of prefix (v6) to create site prefix in"
}

variable "tunnel_peer_names" {
  type        = list(string)
  description = "names of tunnel peers"
}

variable "tunnel_prefix_v4_id" {
  type        = number
  description = "Netbox ID of prefix (v4) to create tunnel prefix in"
}

variable "tunnel_prefix_v6_id" {
  type        = number
  description = "Netbox ID of prefix (v6) to create tunnel prefix in"
}
