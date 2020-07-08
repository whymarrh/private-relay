FROM ubuntu:20.04 AS terraform
ARG TERRAFORM_VERSION='0.12.28'
WORKDIR /tmp
RUN apt-get -qq update && \
    apt-get -qq install curl unzip > /dev/null && \
    curl -sSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    curl -sSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sha256sum --strict --check --ignore-missing "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    unzip -q -n -d '/usr/local/bin' "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

FROM terraform as build
ARG TF_VAR_backends
WORKDIR /proxy
COPY main.tf .
COPY haproxy.cfg.tmpl .
RUN terraform init && \
    terraform apply -auto-approve

FROM haproxy:2.1
COPY --from=build /proxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN haproxy -c -f '/usr/local/etc/haproxy/haproxy.cfg'
