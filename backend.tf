terraform {
  backend "http" {
    address        = "https://ffddorf-terraform-backend.fly.dev/state/terraform-gre-sites/default"
    lock_address   = "https://ffddorf-terraform-backend.fly.dev/state/terraform-gre-sites/default"
    unlock_address = "https://ffddorf-terraform-backend.fly.dev/state/terraform-gre-sites/default"
    username       = "github_pat"
  }
}
