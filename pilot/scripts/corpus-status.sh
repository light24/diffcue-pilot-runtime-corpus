#!/usr/bin/env bash
set -euo pipefail

manifest=${1:-/pilot-repo/pilot/corpus.json}
: "${DIFFCUE_TOKEN:?DIFFCUE_TOKEN is required to verify repository-scoped runners}"

jq -e '
  .schema_version == "diffcue-pilot-corpus-v1" and
  .corpus_kind == "synthetic_operational_protocol" and
  .owner_opt_in.status == "explicit" and
  (.repositories | length >= 2) and
  (.limitations.powered_for_lift == false)
' "$manifest" >/dev/null

rows=$(mktemp)
trap 'rm -f "$rows"' EXIT
printf '[]' > "$rows"

while IFS= read -r repository; do
  repo=$(curl --fail --silent --show-error --location \
    --header "Authorization: Bearer $DIFFCUE_TOKEN" \
    --header 'Accept: application/vnd.github+json' \
    --header 'X-GitHub-Api-Version: 2022-11-28' \
    "https://api.github.com/repos/$repository")
  runners=$(curl --fail --silent --show-error --location \
    --header "Authorization: Bearer $DIFFCUE_TOKEN" \
    --header 'Accept: application/vnd.github+json' \
    --header 'X-GitHub-Api-Version: 2022-11-28' \
    "https://api.github.com/repos/$repository/actions/runners")
  workflow_code=$(curl --silent --show-error --location --output /dev/null --write-out '%{http_code}' \
    --header "Authorization: Bearer $DIFFCUE_TOKEN" \
    --header 'Accept: application/vnd.github+json' \
    --header 'X-GitHub-Api-Version: 2022-11-28' \
    "https://api.github.com/repos/$repository/contents/.github/workflows/diffcue-experiment-check.yml")
  row=$(jq -n --arg repository "$repository" --argjson repo "$repo" --argjson runners "$runners" --arg workflow_code "$workflow_code" '{
    repository: $repository,
    public_synthetic_repository: ($repo.private == false and $repo.archived == false),
    workflow_active: ($workflow_code == "200"),
    online_repo_scoped_runners: ([$runners.runners[] | select(.status == "online")] | length),
    busy_runners: ([$runners.runners[] | select(.busy == true)] | length)
  }')
  jq --argjson row "$row" '. + [$row]' "$rows" > "$rows.next"
  mv "$rows.next" "$rows"
done < <(jq -r '.repositories[].repository' "$manifest")

jq -n --slurpfile manifest "$manifest" --slurpfile rows "$rows" '{
  schema_version: "diffcue-pilot-corpus-status-v1",
  corpus_kind: $manifest[0].corpus_kind,
  claim_boundary: $manifest[0].claim_boundary,
  protocol: $manifest[0].protocol,
  owner_opt_in: $manifest[0].owner_opt_in,
  repositories: $rows[0],
  ready: (([$rows[0][] | select(.public_synthetic_repository and .workflow_active and .online_repo_scoped_runners == 1)] | length) == ($rows[0] | length)),
  limitations: $manifest[0].limitations
}'

jq -e 'all(.[]; .public_synthetic_repository and .workflow_active and .online_repo_scoped_runners == 1)' "$rows" >/dev/null
