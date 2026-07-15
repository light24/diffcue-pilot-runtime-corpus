#!/usr/bin/env bash
set -euo pipefail

repository=${1:?repository is required}
digest_file=${2:?binary digest file is required}
digest=$(tr -d '[:space:]' < "$digest_file")
[[ "$digest" =~ ^[0-9a-f]{64}$ ]] || { echo 'invalid DiffCue binary digest' >&2; exit 1; }

/pilot-repo/pilot/scripts/set-repository-variable.sh "$repository" DIFFCUE_CACHE_DIR /var/lib/diffcue
/pilot-repo/pilot/scripts/set-repository-variable.sh "$repository" DIFFCUE_PROVIDER_STORE /var/lib/diffcue/provider-review
/pilot-repo/pilot/scripts/set-repository-variable.sh "$repository" DIFFCUE_BINARY_SHA256 "$digest"
