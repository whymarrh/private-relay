terraform {
  backend "remote" {
    organization = "www-private-relay"

    workspaces {
      name = "private-relay"
    }
  }
}

variable "do_token" {
  type = string
}

provider "digitalocean" {
  token   = var.do_token
  version = "~> 1.18"
}

provider "docker" {
  version = "~> 2.7"
}

resource "digitalocean_droplet" "private_relay" {
  for_each = toset(["tor1", "ams3"])

  region = each.key
  image  = "ubuntu-20-04-x64"
  name   = "private-relay-1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    "21:ba:db:a6:e6:f4:8f:ac:77:c9:1a:70:f1:81:a0:73"
  ]

  user_data = file("scripts/nginx")

  backups            = false
  ipv6               = false
  private_networking = true
}
