# DiffCue cue-utility pilot v1

This repository is the disposable operational-smoke member of the pilot. It is
not, by itself, a powered corpus and cannot support an effectiveness claim.

## Frozen design

- Repository: `light24/diffcue-pilot-acceptance`
- DiffCue commit: `5414fdc08855214fec7024b0d9d9f58acb3fff7e`
- Assignment unit: canonical provider change episode
- Assignment: deterministic 50% exposed / 50% holdout
- Policy mode: evaluation only
- Policy: `cue-utility-policy-v3-episode-clustered`
- Protocol: `cue-utility-experiment-protocol-v1`
- Outcome definition: `cue-outcome-definition-v2-exact-episode`
- Observation window: 14 days
- Runner: isolated, pinned Actions runner `2.335.1`; no Docker socket

Changing the DiffCue commit, policy, protocol, outcome definition, observation
window, holdout rate, assignment unit, repository set, or required cue families
starts a new cohort. Existing events are never reinterpreted or appended to the
new cohort.

## Acceptance gate

- Baseline outcome rate: 20%
- Minimum detectable lift: 10 percentage points
- Two-sided alpha: 0.05
- Target power: 0.80
- Minimum complete observations: 294 per arm
- Maximum 95% interval width: 0.20
- Minimum family coverage: 30 per arm
- Required families: `exact_linked_test`, `relationship_companion`
- Required episode proof: `provider_event_file`

The current accessible repository set has only five recent PRs, so this gate
cannot be reached yet. Synthetic PRs and operator-supplied outcomes must not be
used to manufacture power.

## Health-only monitoring

During collection run `make pilot-health`. It intentionally omits interim lift
and reports only publication failures, missing/corrupt durable state (as a hard
command failure), unknown/censored rates, arm balance, family coverage, and
repository coverage. Do not tune policy from interim outcomes.

## Activation boundary

The workflow is safe to merge only after:

1. an isolated self-hosted runner is online with label `diffcue-pilot`;
2. `DIFFCUE_CACHE_DIR=/var/lib/diffcue` is configured as a repository variable;
3. `DIFFCUE_BINARY_SHA256` matches the binary built from the frozen commit;
4. fork-origin PRs are excluded;
5. one non-measurement, no-publication smoke passes.

`make pilot-up` prepares the complete environment in one command. A pinned Go
builder container compiles DiffCue into a named read-only binary volume; the
runner, registration bootstrap, durable cache and health tooling are Compose
services/volumes. The host needs only Docker Compose and `DIFFCUE_TOKEN`.
The long-lived token exists only in a removed one-shot bootstrap container and
is exchanged for a short-lived registration token; neither token is written to
the repository or durable experiment cache.

## Local quick start

```bash
cp .env.example .env
# Set the repository/source paths in .env. Keep the credential in the process
# environment under its existing name; do not paste it into .env.
make pilot-up
make pilot-smoke
make pilot-health
```

`make pilot-up` is idempotent. On the first run it builds the frozen DiffCue
binary, exchanges `DIFFCUE_TOKEN` for a short-lived runner registration token,
starts the runner, removes the bootstrap token and configures the two required
GitHub repository variables. On later runs it preserves a healthy running
container and does not issue another registration token.
