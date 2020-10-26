terraform {
  required_version = "~> 0.13.5"
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

variable "region_map_keys" {
  description = "The set of Cloudflare origin pool regions"

  # The ordering of the pools in the load balancer determines the order in
  # which pools in the load balancer will fail over. When the number of
  # healthy origins within a pool goes below the configured threshold,
  # Cloudflare will send traffic to the next available pool - e.g. traffic
  # will always land on Pool #1 until it is marked unhealthy.
  default = [
    "eu",
    "na",
    "ap",
  ]
}

variable "region_map_values" {
  description = "The set of supported regions"
  default = [
    {
      # EU region
      do_regions = ["ams3", "fra1"]
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
    {
      # North American region
      do_regions = ["tor1", "sfo3"]
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
    {
      # Asia-Pacific region
      do_regions = ["sgp1"]
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

module "private_relay" {
  source                          = "./modules/cloudflare-digitalocean"
  name                            = "private-relay"
  do_tag_name                     = "private-relay"
  cf_zone_id                      = var.cf_zone_id
  cf_lb_name                      = var.cf_lb_name
  private_relay_docker_image_name = var.private_relay_docker_image_name
}
