SHELL := /bin/bash
.DEFAULT_GOAL := help

-include .env

COMPOSE := docker compose --env-file .env

.PHONY: help check-env docker-ready pilot-binary runner-token pilot-up pilot-down pilot-reset pilot-status pilot-logs pilot-doctor pilot-smoke pilot-health pilot-final-report github-variables

help:
	@printf '%s\n' \
	  'make pilot-up          One command: build DiffCue, bootstrap and start the isolated runner' \
	  'make pilot-status      Show container and runner health' \
	  'make pilot-logs        Follow runner logs' \
	  'make pilot-doctor      Run prerequisite checks inside Compose' \
	  'make pilot-smoke       Run a containerized no-measurement/no-publication smoke' \
	  'make pilot-health      Show health only; intentionally hides interim lift' \
	  'make github-variables  Freeze cache and binary digest repository variables' \
	  'make pilot-down        Stop without deleting durable state' \
	  'make pilot-reset       Explicitly unregister the runner and delete durable local state'

check-env:
	@test -f .env || { echo 'Copy .env.example to .env' >&2; exit 1; }
	@test -n "$(PILOT_REPOSITORY)" -a -n "$(PILOT_REPO_DIR)" -a -n "$(DIFFCUE_SOURCE_DIR)" -a -n "$(DIFFCUE_COMMIT)"

docker-ready:
	@if docker info >/dev/null 2>&1; then exit 0; fi; \
	  if [[ "$$(uname -s)" = Darwin ]] && command -v open >/dev/null; then \
	    echo 'Starting Docker Desktop...'; open -a Docker; \
	    for _ in $$(seq 1 60); do docker info >/dev/null 2>&1 && exit 0; sleep 2; done; \
	  fi; \
	  echo 'Docker daemon is unavailable' >&2; exit 1

pilot-binary: check-env docker-ready
	@$(COMPOSE) --profile tools run --rm builder

runner-token: check-env docker-ready
	@test -n "$${DIFFCUE_TOKEN:-}" || { echo 'DIFFCUE_TOKEN is required in the process environment' >&2; exit 1; }
	@$(COMPOSE) --profile tools run --build --rm token-init

pilot-up: pilot-binary
	@if $(COMPOSE) ps --status running --services | grep -qx runner; then \
	  echo 'Runner container is already running; registration bootstrap skipped.'; \
	else \
	  $(MAKE) runner-token; \
	  $(COMPOSE) up -d runner; \
	fi
	@$(COMPOSE) --profile tools run --rm github-variables
	@$(COMPOSE) ps

pilot-down:
	@$(COMPOSE) down

pilot-reset: check-env docker-ready
	@printf '%s\n' 'This unregisters the GitHub runner and deletes durable experiment state.'
	@test "$${CONFIRM_RESET:-}" = DELETE || { echo 'Set CONFIRM_RESET=DELETE to continue' >&2; exit 1; }
	@test -n "$${DIFFCUE_TOKEN:-}" || { echo 'DIFFCUE_TOKEN is required in the process environment' >&2; exit 1; }
	@$(COMPOSE) stop runner >/dev/null 2>&1 || true
	@$(COMPOSE) --profile tools run --build --rm runner-unregister
	@$(COMPOSE) down -v

pilot-status:
	@$(COMPOSE) ps

pilot-logs:
	@$(COMPOSE) logs -f --tail=100 runner

pilot-doctor: pilot-binary
	@$(COMPOSE) --profile tools run --rm doctor

pilot-smoke: pilot-binary
	@$(COMPOSE) --profile tools run --rm smoke

pilot-health: pilot-binary
	@$(COMPOSE) --profile tools run --rm health

pilot-final-report: pilot-binary
	@$(COMPOSE) --profile tools run --rm --entrypoint /opt/diffcue/diffcue health pilot cue-utility --cache-dir /var/lib/diffcue --repo /pilot-repo

github-variables: pilot-binary
	@test -n "$${DIFFCUE_TOKEN:-}" || { echo 'DIFFCUE_TOKEN is required in the process environment' >&2; exit 1; }
	@$(COMPOSE) --profile tools run --rm github-variables
