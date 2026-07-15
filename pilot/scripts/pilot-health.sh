#!/usr/bin/env bash
set -euo pipefail

cache=${1:-/var/lib/diffcue}
repo=${2:-/pilot-repo}
events=$(mktemp)
utility=$(mktemp)
trap 'rm -f "$events" "$utility"' EXIT

/opt/diffcue/diffcue pilot export --cache-dir "$cache" --since all --aggregate > "$events"
/opt/diffcue/diffcue pilot cue-utility --cache-dir "$cache" --repo "$repo" > "$utility"

jq -n --slurpfile events "$events" --slurpfile utility "$utility" '{
  schema_version: "diffcue-pilot-health-v1",
  publication_failures: $events[0].errors,
  orphaned_runs: $events[0].orphaned_runs,
  duplicate_runs: $events[0].duplicate_runs,
  missing_or_corrupt_state: false,
  unknown_rate: $utility[0].outcome_quality.unknown_rate,
  censored_rate: $utility[0].outcome_quality.censored_rate,
  arm_balance: {
    exposed: $utility[0].report.summary.exposed.eligible,
    holdout: $utility[0].report.summary.holdout.eligible
  },
  family_coverage: $utility[0].report.family_coverage,
  repository_coverage: {
    selected: $utility[0].repository_count,
    eligible_clusters: $utility[0].eligible_clusters,
    complete_clusters: $utility[0].complete_clusters,
    incomplete_clusters: $utility[0].incomplete_clusters
  },
  interim_lift_hidden: true,
  policy_effect: $utility[0].outcome_quality.policy_effect
}'

jq -e '.errors == 0 and .orphaned_runs == 0 and .duplicate_runs == 0' "$events" >/dev/null
