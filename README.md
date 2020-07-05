[![Private Relay](./docs/images/logo.svg)](https://privaterelay.technology)

A privacy-preserving TCP proxy based on Signal's [_Expanding Signal GIF search_][signal-and-giphy] article.

This README outlines the high-level ideas, see [`CONTRIBUTING.md`](./CONTRIBUTING.md) for information about how to contribute to/build the project.

- [What's the idea here?](#whats-the-idea-here)
- [What does this mean in practice?](#what-does-this-mean-in-practice)
- [How does it work?](#how-does-it-work)
- [What is the benefit?](#what-is-the-benefit)
- [How can I host my own proxy?](#how-can-i-host-my-own-proxy)
  - [Architecture](#architecture)
  - [Costs](#costs)

### What's the idea here?

From Signal's article:<sup>[\[1\]][signal-and-giphy]</sup>

> In order to hide your search term from GIPHY, the Signal service acts as a privacy-preserving proxy.
>
> When querying GIPHY:
>
> 1. The Signal app opens a TCP connection to the Signal service.
> 2. The Signal service opens a TCP connection to the GIPHY HTTPS API endpoint and relays bytes between the app and GIPHY.
> 3. The Signal app negotiates TLS through the proxied TCP connection all the way to the GIPHY HTTPS API endpoint.
>
> Since communication is done via TLS all the way to GIPHY, the Signal service never sees the plaintext contents of what
> is transmitted or received. Since the TCP connection is proxied through the Signal service, GIPHY doesn't know who
> issued the request.
>
> The Signal service essentially acts as a VPN for GIPHY traffic: the Signal service knows who you are, but not what
> you're searching for or selecting. The GIPHY API service sees the search term, but not who you are.

This proxy is an implementation of exactly that.

### What does this mean in practice?

I've deployed an example proxy for [httpbin.org](https://httpbin.org) to `relay.privaterelay.technology`. You can send requests
to httpbin.org through that proxy to hide your IP address from the service.

httpbin.org has a [`/ip`](https://httpbin.org/ip) endpoint that will return the requester's IP address:

```bash
curl -sSL 'https://httpbin.org/ip' | jq '.origin'
# => $ADDRESS1
curl -sSL --connect-to httpbin.org:443:relay.privaterelay.technology:443 'https://httpbin.org/ip' | jq '.origin'
# => $ADDRESS2
# Note that $ADDRESS1 ≠ $ADDRESS2
```

In the example above, `$ADDRESS1` is your external IP address, as expected, while `$ADDRESS2` is the IP address of the
proxy.

(See the cURL man page for: [`--connect-to <HOST1:PORT1:HOST2:PORT2>`][curl---connect-to])

### How does it work?

> *"It's just HAProxy"*

The proxy server runs HAProxy in TCP mode, and the TLS connection passes through. A useful diagram from the HAProxy
docs:<sup>[\[1\]][haproxy-tls-passthrough-docs]</sup>

[![HAProxy TLS pass-through diagram][haproxy-tls-passthrough]][haproxy-tls-passthrough-docs]

HAProxy does not and cannot decipher the traffic.

[You can see the full HAProxy configuration used in `proxy/haproxy.cfg`.](./proxy/haproxy.cfg)

### What is the benefit?

Privacy, mostly, at the cost of an extra TCP connection.

From Signal's article, again:<sup>[\[1\]][signal-and-giphy]</sup>

> [The proxy service] knows who you are, but not what you're searching for or selecting. The GIPHY API service sees
> the search term, but not who you are.

### How can I host my own proxy?

Fork the repo and configure it!

#### Architecture

There are two main components:

1. [Cloudflare Load Balancing](#cloudflare-load-balancing)
2. [HAProxy servers](#haproxy-servers)

##### Cloudflare Load Balancing

(**Note:** this is not used for load balancing per se, more a way of routing users to the closest HAProxy instance.)

The first component is a Cloudflare Load Balancer in DNS-Only mode with a 30 second TTL.

Operating in this mode does have a caveat:

> [This] relies on DNS resolvers respecting the short TTL to  re-query Cloudflare’s DNS for an updated list of healthy addresses.

The DNS-only load balancer does dynamic latency-based DNS resolution via [Dynamic Steering][cf-traffic-steering-dynamic]:

> Dynamic Steering uses health check data to identify the fastest pool for a given Cloudflare Region [...]
>
> Dynamic Steering creates Round Trip Time (RTT) profiles based on an exponential weighted moving average (EWMA) of RTT
> to determine the fastest pool. If there is no current RTT data for your pool in a region or colocation center,
> Cloudflare directs traffic to the pools in failover order.

##### HAProxy servers

As described above, HAProxy runs in TCP mode, and the TLS connection passes through. DigitalOcean hosts the HAProxy
servers.

#### Costs

> *"How much does this cost to host?"*

(All amounts are USD.)

The hosting costs depend on the configured regions and bandwidth usage.

The individual monthly costs:

- DigitalOcean droplet costs vary depending on the droplet size used
    - $5/month for `s-1vcpu-1gb`
- DigitalOcean bandwidth costs: (GB used − 1024 GB × # of droplets per region × # of regions total) × $0.01
    - e.g. 10 TB total outbound would be ~$50/month
- Cloudflare Load Balancing costs
    - $5/month base cost
    - $5/month per additional origin server ($5 × droplet count)
    - $15/month for 15s health checks ([`cloudflare_load_balancer_monitor.simple_tcp_monitor.interval`](./terraform/main.tf))
    - $15 for RTTs in 8 regions
    - $10 for latency-based traffic steering ([`cloudflare_load_balancer.private_relay_lb.steering_policy`](./terraform/main.tf))
    - $0.5 per 500,000 DNS queries

The total monthly costs for the config in this repository:

<table style="vertical-align: middle;">
    <tbody>
        <tr>
            <td rowspan="2">DigitalOcean</td>
            <td>Droplets</td>
            <td align="right">$25</td>
        </tr>
        <tr>
            <td>Bandwidth (~8 TB)</td>
            <td align="right"><a href="https://www.digitalocean.com/community/tools/bandwidth?active=%5B%7B%22slug%22%3A%22s-1vcpu-1gb%22%2C%22type%22%3A%22droplet%22%2C%22hours%22%3A744%2C%22consumption%22%3A8192%2C%22nodes%22%3A1%7D%2C%7B%22slug%22%3A%22s-1vcpu-1gb%22%2C%22type%22%3A%22droplet%22%2C%22hours%22%3A744%2C%22consumption%22%3A0%2C%22nodes%22%3A1%7D%2C%7B%22slug%22%3A%22s-1vcpu-1gb%22%2C%22type%22%3A%22droplet%22%2C%22hours%22%3A744%2C%22consumption%22%3A0%2C%22nodes%22%3A1%7D%2C%7B%22slug%22%3A%22s-1vcpu-1gb%22%2C%22type%22%3A%22droplet%22%2C%22hours%22%3A744%2C%22consumption%22%3A0%2C%22nodes%22%3A1%7D%2C%7B%22slug%22%3A%22s-1vcpu-1gb%22%2C%22type%22%3A%22droplet%22%2C%22hours%22%3A744%2C%22consumption%22%3A0%2C%22nodes%22%3A1%7D%5D">~$30</a></td>
        </tr>
        <tr>
            <td rowspan="6">Cloudflare</td>
            <td>Basic</td>
            <td align="right">$5</td>
        </tr>
        <tr>
            <td>5 origin servers</td>
            <td align="right">$15</td>
        </tr>
        <tr>
            <td>15s checks</td>
            <td align="right">$15</td>
        </tr>
        <tr>
            <td>RTT from 8 regions</td>
            <td align="right">$15</td>
        </tr>
        <tr>
            <td>Latency-based traffic steering</td>
            <td align="right">$10</td>
        </tr>
        <tr>
            <td>DNS (~5.5M queries)</td>
            <td align="right">$5</td>
        </tr>
    </tbody>
    <tfoot>
        <tr>
            <th colspan="2">Total</td>
            <th align="right">~$120</td>
        </tr>
    </tfoot>
</table>

Resources:

- See [DigitalOcean's Bandwidth Calculator][do-bandwidth-calculator] to get official allowance estimations
- See [_Billing for Cloudflare Load Balancing_][cf-lb-billing]

  [signal-and-giphy]:https://signal.org/blog/signal-and-giphy-update/
  [signal-and-giphy-wayback]:https://web.archive.org/web/20200524203345/https://signal.org/blog/signal-and-giphy-update/
  [haproxy-tls-passthrough]:https://user-images.githubusercontent.com/1623628/82765015-cd931580-9ded-11ea-8fd3-8f0dead2e829.png
  [haproxy-tls-passthrough-docs]:https://www.haproxy.com/documentation/haproxy/deployment-guides/tls-infrastructure/#ssl-tls-pass-through
  [curl---connect-to]:https://curl.haxx.se/docs/manpage.html#--connect-to
  [do-bandwidth-calculator]:https://www.digitalocean.com/community/tools/bandwidth
  [cf-lb-billing]:https://support.cloudflare.com/hc/articles/115005254367
  [cf-traffic-steering-dynamic]:https://developers.cloudflare.com/load-balancing/understand-basics/traffic-steering/#dynamic-steering

This repository is available under the ISC License. See [`LICENSE.md`](./LICENSE.md).
