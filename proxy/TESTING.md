 # Testing the image

To run the tests ([`test/`](./test)) against the default config, build the image:

```bash
docker build --tag private-relay .
```

Run HAProxy:

```bash
docker run --rm --detach --publish 8080:443 --name private-relay private-relay
```

And run the tests:

```bash
pushd test/
yarn

GITHUB_API_ENDPOINT='https://api.github.com' \
GITHUB_API_ENDPOINT_RELAY="https://127.0.0.1:8080" \
HTTPBIN_ENDPOINT="https://httpbin.org" \
HTTPBIN_ENDPOINT_RELAY="https://127.0.0.1:8080" \
yarn test

popd
```
