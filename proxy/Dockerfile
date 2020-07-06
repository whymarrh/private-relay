FROM haproxy:2.1
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN haproxy -c -f '/usr/local/etc/haproxy/haproxy.cfg'
