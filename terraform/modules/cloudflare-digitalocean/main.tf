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
}

resource "digitalocean_tag" "private_relay" {
  name = var.do_tag_name
}

resource "digitalocean_floating_ip" "private_relay_server_ip" {
  for_each = toset(flatten([for cfg in var.region_map_values : cfg.do_regions]))

  region = each.key
}

resource "digitalocean_droplet" "private_relay_server" {
  for_each = toset(flatten([for cfg in var.region_map_values : cfg.do_regions]))

  region = each.key
  image  = "ubuntu-20-04-x64"
  name   = "${var.name}-${each.key}"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    "21:ba:db:a6:e6:f4:8f:ac:77:c9:1a:70:f1:81:a0:73"
  ]
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
  for_each = toset(flatten([for cfg in var.region_map_values : cfg.do_regions]))

  ip_address = digitalocean_floating_ip.private_relay_server_ip[each.key].id
  droplet_id = digitalocean_droplet.private_relay_server[each.key].id
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
  description     = "Regional load balancer pool"
  enabled         = true
  minimum_origins = 1
  monitor         = cloudflare_load_balancer_monitor.simple_tcp_monitor.id
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
  zone_id     = var.cf_zone_id
  name        = var.cf_lb_name
  description = "Load balancer with Dynamic Steering"

  ttl              = 30
  default_pool_ids = [for k in var.region_map_keys : cloudflare_load_balancer_pool.private_relay_server_pool[k].id]
  fallback_pool_id = cloudflare_load_balancer_pool.private_relay_server_pool[var.region_map_keys[0]].id
  steering_policy  = "dynamic_latency"
}
