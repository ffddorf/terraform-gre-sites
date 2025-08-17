variable "device_role" {
  type        = string
  description = "Role of devices to use"
  default     = "Router"
}

variable "device_tag" {
  type        = string
  description = "Tag to filter devices by"
  default     = "remote-site-router"
}

variable "sites_prefix_v4" {
  type        = string
  description = "Prefix (v4) to create site prefixes in"
  default     = "45.151.166.0/24"
}

variable "sites_prefix_v6" {
  type        = string
  description = "Prefix (v6) to create site prefixes in"
  default     = "2001:678:b7c::/48"
}

variable "tunnels_prefix_v4" {
  type        = string
  description = "Prefix (v4) to create tunnel prefixes in"
  default     = "10.129.0.0/16"
}

variable "tunnels_prefix_v6" {
  type        = string
  description = "Prefix (v6) to create tunnel prefixes in"
  default     = "fdcb:aa6b:5532::/48"
}

variable "core_router_tag" {
  type        = string
  description = "Tag to use for finding core routers"
  default     = "core-router"
}

variable "tenant_id" {
  type        = number
  description = "NetBox tenant ID to use for all resources"
  default     = 2
}

variable "tenant_tunnels" {
  type = list(object({
    tenant = string # slug
    site   = string # slug

    existing_router = optional(string) # name
    remote_ip       = optional(string)
  }))
  default     = []
  description = "Custom GRE tunnels provided to external tenants"

  validation {
    condition     = alltrue([for t in var.tenant_tunnels : t.existing_router != null || t.remote_ip != null])
    error_message = "Need to specify either existing_router or remote_ip"
  }
}
