#!/usr/bin/env bash
set -euo pipefail

repository=${1:?repository is required}
output=${2:?output path is required}
: "${DIFFCUE_TOKEN:?DIFFCUE_TOKEN is required}"

mkdir -p "$(dirname "$output")"
umask 077
response=$(mktemp "${output}.response.XXXXXX")
token_tmp=$(mktemp "${output}.token.XXXXXX")
trap 'rm -f "$response" "$token_tmp"' EXIT

http_code=$(curl --fail-with-body --silent --show-error --location \
  --output "$response" --write-out '%{http_code}' --request POST \
  --header "Authorization: Bearer $DIFFCUE_TOKEN" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/${repository}/actions/runners/registration-token")
[[ "$http_code" == 201 ]] || { echo "runner token request failed with HTTP $http_code" >&2; exit 1; }

jq --exit-status --raw-output \
  '.token | select(type == "string" and length > 0)' \
  "$response" > "$token_tmp"
chmod 0600 "$token_tmp"
mv "$token_tmp" "$output"
echo 'short-lived runner registration token prepared'
