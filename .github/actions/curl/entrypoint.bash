#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

printf '%s\n' "${INPUT_EXTRA_HOSTS:-}" | envsubst >> /etc/hosts

# shellcheck disable=SC2086
curl ${INPUT_CURL_OPTS:-} "${INPUT_URL:---help}"
