## Context

`web-time` is a Rust library crate providing a drop-in replacement for `std::time` on Wasm targets. Its CI comprises 10 GitHub Actions workflow files that have grown organically. The current state:

- **10 workflows:** `audit.yaml`, `build.yaml`, `test.yaml`, `lint.yaml`, `format.yaml`, `coverage-documentation.yaml`, `spellcheck.yaml`, `merge.yaml`, `publish.yaml`, `upstream.yaml`
- **Duplicated matrix logic**: `build.yaml`, `lint.yaml`, and `test.yaml` each define their own near-identical Rust × target × feature matrices with subtly different exclusion rules.
- **Copy-pasted steps**: "Install Rust", "Set build-std components", and CFLAGS handling appear 4–8 times each across workflows.
- **Zero reuse**: No composite actions, no reusable workflows, no container images.
- **Custom tooling**: Coverage uses a custom `wasm-bindgen` fork, installs Clang 19 via deprecated `apt-key`, and manually extracts `.ll` files.
- **Custom merge bot**: `merge.yaml` implements `/fast-forward-merge` via comment-triggered workflow with JS scripting.
- **Stale version**: `Cargo.toml` is 1.1.0 but `CHANGELOG.md` has substantial unreleased features.

The project has Rust edition 2024 and MSRV 1.87. It targets `wasm32-unknown-unknown` and `wasm32v1-none`, plus native fallback.

## Goals / Non-Goals

**Goals:**
- Reduce CI YAML duplication by 40–60% through reusable workflows and composite actions.
- Preserve all existing build, test, lint, format, audit, and coverage checks.
- Cut PR CI latency by splitting tests into required and optional tiers.
- Eliminate the deprecated `apt-key` pattern and custom `wasm-bindgen` fork in coverage.
- Replace the custom merge bot with GitHub-native Merge Queue.
- Provide local development tooling that mirrors CI checks.
- Finalise the version bump to 2.0.0 before CI refactoring begins.

**Non-Goals:**
- Changing the crate's Rust API or behaviour.
- Adding or removing CI checks (the same things pass/fail, just with less code).
- Migrating away from GitHub Actions (e.g., to BuildJet or self-hosted runners).
- Changing the upstream tracking or dependabot ecosystem.
- Altering the test architecture (`tests-native/`, `tests-web/`, shared `tests/` directory).
- Adding a release automation workflow (out of scope, but the version bump establishes a clean baseline for future automation).

## Decisions

### D1: Reusable workflow over composite action for the core CI matrix

A single `rust-ci.yml` reusable workflow (triggered via `workflow_call`) accepts `command`, `target`, `toolchain`, `features`, and Wasm-specific flags. Callers (`build.yaml`, `lint.yaml`) define only their matrix and delegate.

**Rationale:** A reusable workflow captures the entire job shape (steps, env, conditionals). Composite actions alone can't define `runs-on`, `strategy`, or `timeout-minutes`. Since we need to vary the job-level matrix, a reusable workflow is the right abstraction, with composite actions handling individual steps within it.

**Alternative considered:** Composite actions for everything with callers duplicating the step sequence. Rejected because it doesn't reduce the matrix duplication — each caller would still enumerate the same steps in the same order.

### D2: Three composite actions, not one monolith

`setup-rust`, `setup-wasm`, and `setup-tool` are separate actions rather than a single `setup-all` action.

**Rationale:** Workflows like `format.yaml` need `setup-rust` but not `setup-wasm`. Workflows like `audit.yaml` only need `setup-tool`. Keeping them granular avoids pulling unnecessary dependencies.

**Alternative considered:** One `setup-ci-env` composite action with optional inputs. Rejected because it would become a god-action with complex conditional logic, making it harder to understand and maintain.

### D3: Tiered tests via separate jobs, not conditional steps

Tests are split into `test` (required, runs on PRs) and `test-extra` (optional, runs on main only) as separate workflow jobs rather than conditional steps within a single job.

**Rationale:** GitHub's branch protection rules operate at the job/check level. A single job that conditionally skips steps would always report green, even if the "optional" steps failed. Separate jobs let us mark `test` as required and `test-extra` as optional.

**Alternative considered:** Using `continue-on-error: true` on optional steps. Rejected because it doesn't give clear red/green signal per tier and can't be enforced by branch protection.

### D4: Coverage: containerise first, evaluate cargo-llvm-cov as follow-up

The coverage workflow's biggest fragility is the `wget | apt-key add` pattern and the custom `wasm-bindgen` fork. Containerising with a `Dockerfile.coverage` that pre-bakes Clang and tools solves the immediate apt-key deprecation risk.

**Rationale:** `cargo-llvm-cov` may not yet support Wasm targets with `wasm-bindgen-test` instrumentation. Containerising is a safe, proven approach that eliminates external runtime dependencies. If `cargo-llvm-cov` works, we can adopt it later as a simplification.

**Alternative considered:** Fix `apt-key` in-place by switching to the new `deb822` signed-by pattern. Rejected because it's still a maintenance burden and doesn't address the custom fork dependency.

### D5: GitHub Merge Queue over maintaining the custom merge bot

`merge.yaml` is replaced entirely by native GitHub Merge Queue with `merge_group` triggers on required workflows.

**Rationale:** Merge Queue is a first-class feature with zero user-maintained code. The custom bot (73 lines of YAML + JS, comment parsing, error posting) is a liability with no unique value.

**Alternative considered:** Keeping the bot and adding merge queue as an option. Rejected — maintaining two merge paths creates confusion and the bot offers no advantage over native functionality.

### D6: `justfile` over `Makefile`

**Rationale:** `just` is Rust-idiomatic (used by many Rust projects), has simpler syntax than Make, and supports recipe listing out of the box (`just --list`). No build step is needed — it's purely a command runner.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Reusable workflow doesn't perfectly capture all matrix exclusion edge cases | Diff the list of jobs before/after refactoring. Reusable workflow accepts arbitrary `exclude` blocks via `fromJSON()`. |
| Custom `wasm-bindgen` fork has no upstream equivalent yet | Document the fork's purpose and the tracking issue. Containerise as a stopgap; periodically re-check upstream status. |
| Merge queue requires admin access to branch protection settings | Coordinate with repo owner (@daxpedda). Document the settings change needed. |
| Tiered tests miss a regression only caught by `test-extra` | `test-extra` runs on every push to `main`. A regression would be caught before the next release. Risk is limited to the PR window. |
| `justfile` falls out of sync with CI | CI workflows call the same underlying cargo commands. `justfile` recipes mirror CI steps by convention; a comment at the top of each workflow can reference the corresponding `just` recipe. |

## Open Questions

- Does the custom `wasm-bindgen` fork (`daxpedda/wasm-bindgen` at `d4cb4a5`) have an upstream PR? If so, what's the status? If merged, we can drop the fork and use published `wasm-bindgen-cli`.
- Does `cargo-llvm-cov` support `wasm32-unknown-unknown` with `wasm-bindgen-test` + `-Cinstrument-coverage`? A 15-minute spike can answer this and potentially eliminate the Dockerfile altogether.
- Should the merge queue require all 10 workflows or only a subset? Proposal: require `build`, `test`, `lint`, `format`, `audit`. Keep `coverage-documentation`, `spellcheck`, `publish`, `upstream` as non-blocking.
