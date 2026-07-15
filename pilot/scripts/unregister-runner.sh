#!/usr/bin/env bash
set -euo pipefail

repository=${1:?repository is required}
runner_name=${2:?runner name is required}
: "${DIFFCUE_TOKEN:?DIFFCUE_TOKEN is required}"

response=$(mktemp)
trap 'rm -f "$response"' EXIT

curl --fail --silent --show-error --location \
  --output "$response" \
  --header "Authorization: Bearer $DIFFCUE_TOKEN" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/${repository}/actions/runners"

matches=$(jq --arg name "$runner_name" '[.runners[] | select(.name == $name)] | length' "$response")
if [[ "$matches" == 0 ]]; then
  echo 'runner is already absent from GitHub'
  exit 0
fi
[[ "$matches" == 1 ]] || { echo 'runner name is not unique; refusing deletion' >&2; exit 1; }

runner_id=$(jq --exit-status --raw-output --arg name "$runner_name" \
  '.runners[] | select(.name == $name) | .id' "$response")
code=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' \
  --request DELETE \
  --header "Authorization: Bearer $DIFFCUE_TOKEN" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  "https://api.github.com/repos/${repository}/actions/runners/${runner_id}")
[[ "$code" == 204 ]] || { echo "runner removal failed with HTTP $code" >&2; exit 1; }
echo 'runner unregistered from GitHub'
