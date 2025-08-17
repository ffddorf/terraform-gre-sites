variable "tenant" {
  type        = string
  description = "Slug of the tenant"
}

variable "site" {
  type        = string
  description = "Slug of the site to use"
}

variable "existing_router" {
  type        = string
  description = "Name of the device to use when not creating one"
  default     = null
}

variable "device_name" {
  type        = string
  description = "Name to use when existing_router is not set"
  default     = null
}

variable "remote_ip" {
  type        = string
  description = "IPv4 address to use as tunnel endpoint when existing_router is not set"
  default     = null
}

variable "core_tunnels" {
  type = list(object({
    name            = string
    device_id       = string
    device_type     = string
    primary_ipv4_id = number
  }))
  description = "info about tunnel peers"
}

variable "sites_prefix_v4_id" {
  type = number
}

variable "sites_prefix_v6_id" {
  type = number
}

variable "tunnel_prefix_v4_id" {
  type = number
}

variable "tunnel_vrf_v4_id" {
  type = number
}

variable "tunnel_prefix_v6_id" {
  type = number
}

variable "tunnel_vrf_v6_id" {
  type = number
}

variable "tunnel_prefix_role_id" {
  type = number
}

variable "tunnel_group_id" {
  type = number
}
