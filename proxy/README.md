# HAProxy config

## Quick start

To build the HAProxy image:

```bash
docker build -t private-relay .
```

To test the config:

```bash
docker run --rm -it private-relay haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
```

To run the image:

```bash
docker run --rm -it -p 8080:443 private-relay
```

To test the image:

```bash
MY_IP='x.x.x.x'
docker build -t private-relay-client -f test/Dockerfile .
docker run --rm --add-host api.github.com:$IP private-relay-client \
    curl -sSL -D - -H 'Host: api.github.com' https://api.github.com:8080
```
