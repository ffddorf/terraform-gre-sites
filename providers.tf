terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 4.2.0"
    }
  }
}

provider "netbox" {
  server_url = "https://netbox.freifunk-duesseldorf.de"
}
