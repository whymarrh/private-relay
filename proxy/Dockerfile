FROM alpine:3 AS build
WORKDIR /tmp
RUN apk add --no-cache curl \
    && curl -sSLO \
        'https://github.com/TypedSoftware/templatefile/releases/download/v1.1.0/templatefile-v1.1.0-linux-amd64.tar.xz' \
    && tar xf templatefile-v1.1.0-linux-amd64.tar.xz

FROM haproxy:2.2-alpine
ARG BUILD_DATE
ARG BUILD_REVISION
LABEL org.opencontainers.image.title="Private Relay" \
      org.opencontainers.image.description="A privacy-preserving TCP proxy" \
      org.opencontainers.image.url="https://privaterelay.technology" \
      org.opencontainers.image.source="https://git.privaterelay.technology" \
      org.opencontainers.image.documentation="https://git.privaterelay.technology" \
      org.opencontainers.image.licenses="ISC" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$BUILD_REVISION \
      org.opencontainers.image.revision=$BUILD_REVISION
WORKDIR /app
COPY --from=build /tmp/templatefile /usr/local/bin/
COPY . .
RUN templatefile haproxy.cfg.tmpl haproxy.cfg.yaml > /usr/local/etc/haproxy/haproxy.cfg \
                                    && haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
