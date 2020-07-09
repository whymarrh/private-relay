# HAProxy config

## Quick start

Build the HAProxy config and image:

```bash
docker build --tag private-relay .
```

To run HAProxy:

```bash
docker run --rm --detach --publish 8080:443 --name private-relay private-relay
```

To test the config:

```
pushd test/
yarn

GITHUB_API_ENDPOINT='https://api.github.com' \
GITHUB_API_ENDPOINT_RELAY="https://127.0.0.1:8080" \
HTTPBIN_ENDPOINT="https://httpbin.org" \
HTTPBIN_ENDPOINT_RELAY="https://127.0.0.1:8080" \
yarn test

popd
```

## Building a custom HAProxy config

```bash
TF_VAR_backends='[{"name":"google","host":"google.com","port":"443"}]'
docker build --build-arg TF_VAR_backends' --tag private-relay .
```
