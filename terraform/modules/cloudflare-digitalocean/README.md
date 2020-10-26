<a href="https://privaterelay.technology">
<img alt="Private Relay" src="https://privaterelay.technology/images/logo/512x256/light@2x.png" width="512px">
</a>

A privacy-preserving TCP proxy based on Signal's [_Expanding Signal GIF search_][signal-and-giphy] article.

[See GitHub for more context →](https://git.privaterelay.technology)

This module allows you to run a Private Relay on a set of DigitalOcean droplets behind a Cloudflare Load Balancer.

## Compatibility

This module requires:

- ✅ Terraform 0.13 or newer
- ✅ [A Cloudflare account](https://dash.cloudflare.com/)
- ✅ [A DigitalOcean account](https://cloud.digitalocean.com/)

## Usage

A simple usage:

```tf
module "private_relay" {
  source = "https://privaterelay.technology"

  name                            = "private-relay"
  do_tag_name                     = "private-relay"
  cf_zone_id                      = "fh7eew2xxxxxxx98fdx2fh7eew2xxxxx"
  cf_lb_name                      = "relay.example.com"
  private_relay_docker_image_name = "org/custom-private-relay-backends"
  region_map_keys = [
    "eu",
  ]
  region_map_values = [
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
  ]
}
```

## License

[View license information for this module.](./LICENSE.md)

  [signal-and-giphy]:https://signal.org/blog/signal-and-giphy-update/
