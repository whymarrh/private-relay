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

variable "cf_email" {
  type = string
}

variable "cf_api_key" {
  type = string
}

variable "cf_zone_id" {
  type = string
}

variable "cf_lb_name" {
  type = string
}

provider "digitalocean" {
  version = "~> 1.18"
  token   = var.do_token
}

provider "cloudflare" {
  version = "~> 2.7"
  email   = var.cf_email
  api_key = var.cf_api_key
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
    "na",
    "eu",
    "ap",
  ]
}

variable "region_map_values" {
  description = "The set of supported regions"
  default = [
    {
      # North American region
      do_regions    = ["tor1", "sfo3"]
      check_regions = ["WNAM"]
    },
    {
      # EU region
      do_regions    = ["ams3", "fra1"]
      check_regions = ["WEU"]
    },
    {
      # Asia-Pacific region
      do_regions    = ["sgp1"]
      check_regions = ["SEAS"]
    },
  ]
}

resource "digitalocean_droplet" "private_relay_server" {
  for_each = toset(flatten([for cfg in var.region_map_values : cfg.do_regions]))

  region = each.key
  image  = "ubuntu-20-04-x64"
  name   = "private-relay-${each.key}"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    "21:ba:db:a6:e6:f4:8f:ac:77:c9:1a:70:f1:81:a0:73"
  ]

  user_data = templatefile("userdata.bash", {
    docker_image_name = var.private_relay_docker_image_name
  })

  backups            = false
  ipv6               = false
  private_networking = true
}

resource "cloudflare_load_balancer_monitor" "simple_tcp_monitor" {
  description = "Simple TCP monitor"
  type        = "tcp"
  port        = 443
  method      = "connection_established"
  timeout     = 1
  interval    = 15
  retries     = 3
}

resource "cloudflare_load_balancer_pool" "private_relay_server_pool" {
  for_each = zipmap(var.region_map_keys, var.region_map_values)

  name            = each.key
  description     = "example load balancer pool"
  enabled         = true
  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.simple_tcp_monitor.id
  check_regions   = each.value.check_regions

  dynamic "origins" {
    for_each = each.value.do_regions

    content {
      name    = origins.value
      address = digitalocean_droplet.private_relay_server[origins.value].ipv4_address
      weight  = 1
      enabled = true
    }
  }
}

resource "cloudflare_load_balancer" "private_relay_lb" {
  zone_id     = var.cf_zone_id
  name        = var.cf_lb_name
  description = "Cloudflare load balancer with Dynamic Steering"

  ttl              = 30
  default_pool_ids = [for k in var.region_map_keys : cloudflare_load_balancer_pool.private_relay_server_pool[k].id]
  fallback_pool_id = cloudflare_load_balancer_pool.private_relay_server_pool[var.region_map_keys[0]].id
  steering_policy  = "dynamic_latency"
}
