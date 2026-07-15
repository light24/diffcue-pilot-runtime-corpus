#!/usr/bin/env bash
set -euo pipefail

repository=${1:?repository is required}
name=${2:?variable name is required}
value=${3:?variable value is required}
: "${DIFFCUE_TOKEN:?DIFFCUE_TOKEN is required}"

base="https://api.github.com/repos/${repository}/actions/variables"
common=(--silent --show-error --header "Authorization: Bearer $DIFFCUE_TOKEN" --header 'Accept: application/vnd.github+json' --header 'X-GitHub-Api-Version: 2022-11-28')
existing=$(curl "${common[@]}" --output /dev/null --write-out '%{http_code}' "${base}/${name}")
payload=$(jq --compact-output --null-input \
  --arg name "$name" \
  --arg value "$value" \
  '{name: $name, value: $value}')
if [[ "$existing" == 200 ]]; then
  code=$(curl "${common[@]}" --output /dev/null --write-out '%{http_code}' --request PATCH --header 'Content-Type: application/json' --data-binary "$payload" "${base}/${name}")
  [[ "$code" == 204 ]] || { echo "update $name failed with HTTP $code" >&2; exit 1; }
else
  code=$(curl "${common[@]}" --output /dev/null --write-out '%{http_code}' --request POST --header 'Content-Type: application/json' --data-binary "$payload" "$base")
  [[ "$code" == 201 ]] || { echo "create $name failed with HTTP $code" >&2; exit 1; }
fi
echo "repository variable $name configured"
