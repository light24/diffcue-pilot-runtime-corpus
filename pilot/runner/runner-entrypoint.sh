#!/usr/bin/env bash
set -euo pipefail

cd /home/runner/actions-runner

token_file=/run/bootstrap/runner-registration-token
if [[ ! -f .runner ]]; then
  [[ -s "$token_file" ]] || { echo 'runner registration token is missing' >&2; exit 1; }
  registration_token=$(<"$token_file")
  ./config.sh --unattended --replace --disableupdate \
    --url "$RUNNER_REPOSITORY_URL" \
    --token "$registration_token" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work _work
  unset registration_token
fi
rm -f "$token_file"

exec ./run.sh
