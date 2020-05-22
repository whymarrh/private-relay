FROM haproxy:2.1
ARG PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN sed --in-place \
    "s/__PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS__/$PRIVATE_RELAY_ORIGIN_SERVER_ADDRESS/" \
    '/usr/local/etc/haproxy/haproxy.cfg'
