variable "device_id" {
  type        = number
  description = "Netbox ID of the device"
}

variable "name" {
  type        = string
  description = "name of the device"
}

variable "wan_interface" {
  type        = string
  description = "Name of the interface used for WAN"
}

variable "allocate_local_net" {
  type        = bool
  description = "Whether to create a VRF and local address resources for the site"
}

variable "use_dnat_for_gre" {
  type        = bool
  description = "Whether to create a static private IP for DNAT of GRE traffic at the site"
  default     = false
}

variable "sites_prefix_v4_id" {
  type        = number
  description = "Netbox ID of prefix (v4) to create site prefix in"
}

variable "sites_prefix_v6_id" {
  type        = number
  description = "Netbox ID of prefix (v6) to create site prefix in"
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

variable "tunnel_group_id" {
  type        = number
  description = "ID of the tunnel group to create tunnels in"
}

variable "tunnel_prefix_v4_id" {
  type        = number
  description = "Netbox ID of prefix (v4) to create tunnel prefix in"
}

variable "tunnel_vrf_v4_id" {
  type        = number
  description = "Netbox ID of VRF for the v4 tunnel prefix"
}

variable "tunnel_prefix_v6_id" {
  type        = number
  description = "Netbox ID of prefix (v6) to create tunnel prefix in"
}

variable "tunnel_vrf_v6_id" {
  type        = number
  description = "Netbox ID of VRF for the v6 tunnel prefix"
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

variable "gre_dnat_ip" {
  type        = string
  description = "Private IP addressed used to receive GRE packets from the CPE"
  default     = "192.168.178.10/24"
}

variable "tunnel_endpoint_address_id" {
  type        = number
  description = "Netbox ID of address to use as tunnel endpoint for this device in case DNAT is not used for GRE"
  default     = null

  validation {
    condition     = var.use_dnat_for_gre || var.tunnel_endpoint_address_id != null
    error_message = "When use_dnat_for_gre is not set, this needs to be set"
  }
}
