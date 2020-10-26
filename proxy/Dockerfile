FROM ubuntu:20.04 AS terraform
ARG TERRAFORM_VERSION='0.13.5'
WORKDIR /tmp
RUN apt-get -qq update && \
    apt-get -qq install curl unzip > /dev/null && \
    curl -sSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    curl -sSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sha256sum --strict --check --ignore-missing "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    unzip -q -n -d '/usr/local/bin' "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

FROM haproxy:2.2-alpine
WORKDIR /app
ENV CHECKPOINT_DISABLE=1
ENV TF_INPUT=0
ENV TF_IN_AUTOMATION=1
ENV TF_LOG=
COPY --from=terraform /usr/local/bin/terraform /usr/local/bin/terraform
COPY . .
RUN apk add --no-cache bash && ./build-config
