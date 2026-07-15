# DiffCue Pilot Acceptance

Public disposable repository for validating DiffCue against real GitHub commits, pull requests, reviews, workflows, and Check Runs.

All source code and history in this repository are synthetic and intentionally shaped for acceptance testing.

The frozen operational corpus is declared in `pilot/corpus.json`. It currently
uses three public synthetic repositories, each with its own repository-scoped
runner and durable cache. Run `make corpus-status` to verify repository,
workflow, runner, protocol, and owner-opt-in state.

This corpus is intentionally not powered for efficacy claims. It validates the
measurement protocol; it does not prove that cues improve human reviews.
