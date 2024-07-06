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

variable "tunnel_group_id" {
  type        = number
  description = "ID of the tunnel group to create tunnels in"
}

variable "tunnel_prefix_v4_id" {
  type        = number
  description = "Netbox ID of prefix (v4) to create tunnel prefix in"
}

variable "tunnel_prefix_v6_id" {
  type        = number
  description = "Netbox ID of prefix (v6) to create tunnel prefix in"
}

variable "networks" {
  type = list(object({
    id   = number
    name = string
  }))
  description = "client networks to create"
  default = [
    {
      id   = 1
      name = "Management"
    },
    {
      id   = 2
      name = "Access"
    },
  ]
}

variable "site_id" {
  type        = number
  description = "Netbox ID of the site"
}

variable "client_prefix_v4" {
  type        = string
  description = "private network to assign client subnets from"
  default     = "10.0.0.0/8"
}

variable "tunnel_prefix_role_id" {
  type        = number
  description = "Netbox ID of the role for tunnel prefixes"
}

variable "tenant_id" {
  type        = number
  description = "NetBox tenant ID to use for all resources"
  default     = 1
}
