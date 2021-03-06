terraform {
  required_version = "~> 0.14.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.12"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "remote" {
    organization = "www-private-relay"

    workspaces {
      name = "private-relay"
    }
  }
}

variable "do_token" {
  description = "The DigitalOcean API token"
  type        = string
}

variable "cf_email" {
  description = "The Cloudflare account email address"
  type        = string
}

variable "cf_api_key" {
  description = "The Cloudflare account API key"
  type        = string
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  email   = var.cf_email
  api_key = var.cf_api_key
}

variable "cf_zone_id" {
  description = "The Zone ID for the load balancer"
  type        = string
}

variable "cf_lb_name" {
  description = "The domain name for the load balancer"
  type        = string
}

variable "private_relay_docker_image_name" {
  description = "The publicly-accessible Docker image name to run on each server"
  type        = string
}

module "private_relay" {
  source                          = "./modules/cloudflare-digitalocean"
  name                            = "private-relay"
  do_tag_name                     = "private-relay"
  cf_zone_id                      = var.cf_zone_id
  cf_lb_name                      = var.cf_lb_name
  private_relay_docker_image_name = var.private_relay_docker_image_name

  do_droplet_ssh_keys = [
    "a8:d9:d8:54:04:18:77:63:73:0e:1f:e4:52:84:6b:6f"
  ]

  # A single Asia-Pacific region with a single droplet
  origin_pools = [
    {
      name       = "ap"
      do_regions = ["blr1"]
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
  ]
}
