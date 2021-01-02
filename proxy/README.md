<a href="https://privaterelay.technology">
<img alt="Private Relay" src="https://privaterelay.technology/images/logo/512x256/light@2x.png" width="512px">
</a>

Private Relay is a privacy-preserving TCP proxy—essentially [HAProxy][haproxy] in `mode tcp`—that facilitates IP anonymization when routing multiple clients traffic through it.

[See the GitHub repository for more context →](https://git.privaterelay.technology)

As a quick example of the functionality, `relay.privaterelay.technology` runs this image with the default config:

```bash
curl -sSL 'https://httpbin.org/ip' | jq '.origin'
# => $ADDRESS1
curl -sSL --connect-to httpbin.org:443:relay.privaterelay.technology:443 'https://httpbin.org/ip' | jq '.origin'
# => $ADDRESS2
```

Note that `$ADDRESS1` ≠ `$ADDRESS2`. 🥳

## How to use this image

This image is the base `haproxy` image with a custom config—[please see the upstream documentation as well](https://hub.docker.com/_/haproxy).

1️⃣ Create a `backends.yaml` file with a set of backend servers:

```yml
backends:
- name: httpbin
  host: httpbin.org
  port: 443
```

2️⃣ Use this as a base image, `COPY backends.yaml /app/`, running `templatefile` to generate the config:

```Dockerfile
FROM privaterelay/privaterelay
RUN templatefile /app/haproxy.cfg.tmpl /app/backends.yaml > /usr/local/etc/haproxy/haproxy.cfg
```

3️⃣ Start your container:

```bash
docker run --rm --detach --publish 8080:443 --name private-relay private-relay
```

HAProxy is now running on the host's `:8080`.

## License

[View license information for this image.](https://git.privaterelay.technology/blob/master/LICENSE.md)

  [1]:https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files
  [haproxy]:https://www.haproxy.org
