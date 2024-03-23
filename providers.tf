terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "3.8.4"
    }
  }
}

provider "netbox" {
  server_url = "https://netbox.freifunk-duesseldorf.de"
}