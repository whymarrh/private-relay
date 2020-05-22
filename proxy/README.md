# HAProxy config

## Quick start

Build the images:

```bash
# A GitHub API relay
PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS='api.github.com:443' \
docker build --build-arg PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS --tag private-relay-github .

# A httpbin.org relay
PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS='httpbin.org:443' \
docker build --build-arg PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS --tag private-relay-httpbin .
```

To run the images:

```bash
terraform apply
```

To test the images:

```
pushd test/
yarn

GITHUB_API_ENDPOINT='https://api.github.com' \
GITHUB_API_ENDPOINT_RELAY="https://127.0.0.1:8080" \
HTTPBIN_ENDPOINT="https://httpbin.org" \
HTTPBIN_ENDPOINT_RELAY="https://127.0.0.1:9090" \
yarn test

popd
```

To remove the running containers:

```bash
terraform destroy
```
