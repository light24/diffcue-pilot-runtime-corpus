#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
manifest=${1:-$repo_root/pilot/corpus.json}
corpus_root=${DIFFCUE_CORPUS_ROOT:-$(dirname "$repo_root")}
rows=$(mktemp)
trap 'rm -f "$rows" "$rows.next"' EXIT
printf '[]' > "$rows"

while IFS= read -r repository; do
  slug=${repository#*/}
  local_repo=$corpus_root/$slug
  [[ -d "$local_repo/.git" && -f "$local_repo/.env" ]] || {
    echo "local opted-in corpus checkout is missing: $slug" >&2
    exit 1
  }
  health=$(cd "$local_repo" && docker compose --env-file .env --profile tools run --rm health </dev/null)
  jq -e '.schema_version == "diffcue-pilot-health-v1"' <<<"$health" >/dev/null
  row=$(jq -n --arg repository "$repository" --argjson health "$health" '{repository: $repository, health: $health}')
  jq --argjson row "$row" '. + [$row]' "$rows" > "$rows.next"
  mv "$rows.next" "$rows"
done < <(jq -r '.repositories[].repository' "$manifest")

jq -n --slurpfile manifest "$manifest" --slurpfile rows "$rows" '{
  schema_version: "diffcue-pilot-corpus-health-v1",
  corpus_kind: $manifest[0].corpus_kind,
  claim_boundary: $manifest[0].claim_boundary,
  repositories: $rows[0],
  ready: all($rows[0][]; .health.publication_failures == 0 and .health.orphaned_runs == 0 and .health.duplicate_runs == 0),
  interim_lift_hidden: true,
  limitations: $manifest[0].limitations
}'

jq -e 'all(.[]; .health.publication_failures == 0 and .health.orphaned_runs == 0 and .health.duplicate_runs == 0)' "$rows" >/dev/null
