variable "name" {
  description = "The name for this Private Relay instance, should be unique"
  type        = string
}

variable "cf_zone_id" {
  description = "The Zone ID for the Cloudflare load balancer"
  type        = string
}

variable "cf_lb_name" {
  description = "The domain name for the Cloudflare load balancer"
  type        = string
}

variable "do_tag_name" {
  description = "The name of the tag to use for the DigitalOcean droplets"
  type        = string
}

variable "do_droplet_size" {
  description = "The size of the DigitalOcean Droplet to create"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "do_droplet_ssh_keys" {
  description = "A list of SSH IDs or fingerprints to authorize for the droplets"
  type        = list(string)
  default     = []
}

variable "private_relay_docker_image_name" {
  description = "The publicly-accessible Docker image name to run on each server"
  type        = string
  default     = "privaterelay/privaterelay"
}

variable "origin_pools" {
  description = "The set of Cloudflare origin pool regions and their corresponding DigitalOcean regions and checks"
  type = list(
    object({
      name          = string
      do_regions    = list(string)
      check_regions = list(string)
    })
  )

  # The ordering of the pools in the load balancer determines the order in
  # which pools in the load balancer will fail over. When the number of
  # healthy origins within a pool goes below the configured threshold,
  # Cloudflare will send traffic to the next available pool - e.g. traffic
  # will always land on Pool #1 until it is marked unhealthy.
  default = [
    # EU region
    {
      name = "eu"
      # Backed by these DigitalOcean regions
      do_regions = ["ams3", "fra1"]
      # RTT-tested from these regions
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
    # North American region
    {
      name = "na"
      # Backed by these DigitalOcean regions
      do_regions = ["tor1", "sfo3"]
      # RTT-tested from these regions
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
    # Asia-Pacific region
    {
      name = "ap"
      # Backed by these DigitalOcean regions
      do_regions = ["sgp1"]
      # RTT-tested from these regions
      check_regions = [
        "WNAM", "ENAM", # North America
        "SSAM",         # South America
        "OC",           # Oceania
        "WEU", "EEU",   # Europe
        "SEAS", "NEAS", # Asia
      ]
    },
  ]

  validation {
    condition     = length(var.origin_pools) > 0
    error_message = "Cloudflare origin pool list must be non-empty."
  }

  validation {
    condition = (
      length(var.origin_pools) == length(distinct([for pool in var.origin_pools : pool.name]))
    )
    error_message = "Cloudflare origin pool names must be unique."
  }

  validation {
    condition = (
      ! contains(
        [for pool in var.origin_pools : (length(pool.check_regions) == length(distinct(pool.check_regions)))],
        false,
      )
    )
    error_message = "Each set of check_regions must not contain duplicates."
  }

  validation {
    condition = (
      ! contains(
        [for pool in var.origin_pools : can(regex("^[a-zA-Z0-9-_]+$", pool.name))],
        false,
      )
    )
    error_message = "Only alphanumeric characters, hyphens and underscores are allowed in origin pool names."
  }
}
