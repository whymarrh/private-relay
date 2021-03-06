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
}

locals {
  do_regions = distinct(flatten([for pool in var.origin_pools : pool.do_regions]))

  # If we only have one DO region configured, we do not need a load balancer
  # and can instead create an A record pointing directly to the droplet. This
  # is useful for demo instances but a production environment will want to
  # route traffic to droplets based on latency. This is a cost optimization.
  cf_record_count = (
    length(local.do_regions) == 1 && length(var.origin_pools) == 1
    ? 1
    : 0
  )
  cf_lb_count = (
    length(local.do_regions) == 1 && length(var.origin_pools) == 1
    ? 0
    : 1
  )

  cf_lb_name__tld = regex("[.][^.]+$", var.cf_lb_name)
  cf_lb_name__tld_stripped = (
    trimsuffix(
      var.cf_lb_name,
      local.cf_lb_name__tld,
    )
  )
  cf_record_name = (
    trimsuffix(
      local.cf_lb_name__tld_stripped,
      regex("[.][^.]+$", local.cf_lb_name__tld_stripped),
    )
  )
}

resource "digitalocean_tag" "private_relay" {
  name = var.do_tag_name
}

resource "digitalocean_floating_ip" "private_relay_server_ip" {
  for_each = toset(local.do_regions)

  region = each.key
}

resource "digitalocean_droplet" "private_relay_server" {
  for_each = toset(local.do_regions)

  region   = each.key
  image    = "ubuntu-20-04-x64"
  name     = "${var.name}-${each.key}"
  size     = var.do_droplet_size
  ssh_keys = var.do_droplet_ssh_keys
  tags = [
    digitalocean_tag.private_relay.id,
  ]

  user_data = templatefile("${path.module}/userdata.bash", {
    docker_image_name = var.private_relay_docker_image_name
  })

  monitoring         = true
  backups            = false
  ipv6               = false
  private_networking = true
}

resource "digitalocean_firewall" "private_relay_firewall" {
  name = "${var.name}-firewall"

  # Droplet tags
  tags = [
    digitalocean_tag.private_relay.id,
  ]

  inbound_rule {
    protocol = "icmp"
    source_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "443"
    source_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }

  outbound_rule {
    protocol = "icmp"
    destination_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }

  outbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }

  outbound_rule {
    protocol   = "udp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0", # All IPv4
      "::/0",      # All IPv6
    ]
  }
}

resource "digitalocean_floating_ip_assignment" "private_relay_server_ip_assignment" {
  for_each = toset(local.do_regions)

  ip_address = digitalocean_floating_ip.private_relay_server_ip[each.key].id
  droplet_id = digitalocean_droplet.private_relay_server[each.key].id
}

resource "cloudflare_record" "private_relay_dns_record" {
  count = local.cf_record_count

  zone_id = var.cf_zone_id
  name    = local.cf_record_name
  type    = "A"
  value   = digitalocean_floating_ip_assignment.private_relay_server_ip_assignment[local.do_regions[0]].ip_address
  proxied = false
}

resource "cloudflare_load_balancer_monitor" "simple_tcp_monitor" {
  count = local.cf_lb_count

  description = "Simple TCP monitor"
  type        = "tcp"
  port        = 443
  method      = "connection_established"
  timeout     = 1
  interval    = 15
  retries     = 3
}

resource "cloudflare_load_balancer_pool" "private_relay_server_pool" {
  for_each = (
    local.cf_lb_count == 0
    ? {}
    : (
      zipmap(
        [for pool in var.origin_pools : pool.name],
        [for pool in var.origin_pools : pool],
      )
  ))

  name            = each.key
  description     = "Regional load balancer pool"
  enabled         = true
  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.simple_tcp_monitor[0].id
  check_regions   = each.value.check_regions

  dynamic "origins" {
    for_each = each.value.do_regions

    content {
      name    = origins.value
      address = digitalocean_floating_ip_assignment.private_relay_server_ip_assignment[origins.value].ip_address
      weight  = 1
      enabled = true
    }
  }
}

resource "cloudflare_load_balancer" "private_relay_lb" {
  count = local.cf_lb_count

  zone_id     = var.cf_zone_id
  name        = var.cf_lb_name
  description = "Load balancer with Dynamic Steering"

  ttl = 30
  # A list of Pool IDs ordered by failover priority. Cloudflare steers traffic to the first pool in the list,
  # failing over to the next healthy pool and so on down the list. This is used instead of `region_pools` or
  # `pop_pools` to allow Dynamic Steering to use its Round Trip Time (RTT) profiles to determine the fastest pool.
  default_pool_ids = [
    for pool in var.origin_pools :
    cloudflare_load_balancer_pool.private_relay_server_pool[pool.name].id
  ]
  # The Pool ID for the "pool of last resort," the pool the load balancer should direct traffic to
  # if all other pools are unhealthy. Here we're falling back to the first/0th pool provided.
  fallback_pool_id = cloudflare_load_balancer_pool.private_relay_server_pool[var.origin_pools[0].name].id
  steering_policy  = "dynamic_latency"
}
