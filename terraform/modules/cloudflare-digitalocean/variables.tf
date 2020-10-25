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
