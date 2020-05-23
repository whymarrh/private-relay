# This Dockerfile is simple way to get a test working with cURL
#
# To test the proxy with cURL one might try:
#
# ```bash
# # With the GitHub API container runnin 8080:443
# curl -vvvs --header 'Host: api.github.com' "https://127.0.0.1:8080"
# ```
#
# That won't work. cURL will complain that the cert doesn't match:
#
# > curl: (60) SSL: no alternative certificate subject name matches target host name '127.0.0.1'
# > More details here: https://curl.haxx.se/docs/sslcerts.html
# >
# > curl failed to verify the legitimacy of the server and therefore could not
# > establish a secure connection to it. To learn more about this situation and
# > how to fix it, please visit the web page mentioned above.
#
#
# And apparently cURL doesn't have a way to validate a certificate name against
# the `Host` header instead of the host of the URL you provide. Using Docker we
# can easily add a host entry via `--add-host`:
#
# ```bash
# MY_LOCAL_IP='x.x.x.x'
# docker build --tag private-relay-client --file test/Dockerfile .
# docker run --rm --add-host api.github.com:"${MY_LOCAL_IP}" private-relay-client \
#    curl -vvvs --header 'Host: api.github.com' https://api.github.com:8080
# ```

FROM alpine:3
RUN apk add --no-cache \
    bash \
    curl
