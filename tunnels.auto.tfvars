tenant_tunnels = [
  {
    tenant = "franzfreunde"
    site   = "franzfreunde"

    existing_router = "R70"
  },
  {
    tenant = "freifunk-troisdorf"
    site   = "bruesseler-strasse"

    remote_ip = "213.168.81.93/29"
    asn       = 64512
    platform  = "EdgeOS"
  },
  {
    tenant = "freifunk-troisdorf"
    site   = "bonner-strasse"

    remote_ip = "77.37.108.81/29"
    asn       = 64513
    platform  = "EdgeOS"
  },
]
