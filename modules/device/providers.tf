terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0.0"
    }
    netboxbgp = {
      source  = "ffddorf/netbox-bgp"
      version = "0.1.0-rc6"
    }
  }
}
