## Why

The CI pipeline has accumulated significant duplication across 10 workflow files — the same Rust × target × feature matrices are independently defined in `build.yaml`, `lint.yaml`, and `test.yaml` with subtly different exclusion rules, and common step sequences are copy-pasted verbatim. Meanwhile, significant unreleased features sit in the changelog while the crate version is stale at 1.1.0. This slows down iteration, makes adding a new Rust version or feature combo error-prone, and creates an ambiguous release state.

## What Changes

- **BREAKING:** Bump crate version from 1.1.0 to 2.0.0, reflecting the new default features (`std`, `msrv`), `wasm32v1-none` target support, and raised MSRV (1.87).
- Introduce reusable GitHub Actions workflows and composite actions to eliminate duplicated step sequences and matrix definitions.
- Split the test matrix into required (PR-blocking) and optional (main-only) tiers to reduce CI latency without sacrificing coverage.
- Containerise the coverage workflow or simplify it with `cargo-llvm-cov`, removing the deprecated `apt-key` pattern and custom `wasm-bindgen` fork if possible.
- Replace the custom `/fast-forward-merge` comment bot with GitHub Merge Queue.
- Add a `justfile` for local development parity with CI, reduce Dependabot to weekly, and introduce `cargo-hack` for feature combination testing.

## Capabilities

### New Capabilities

- `version-management`: Crate version bump to 2.0.0, changelog finalisation, and release process documentation.
- `ci-reusable-workflows`: Shared GitHub Actions workflows (`rust-ci`) and composite actions (`setup-rust`, `setup-wasm`, `setup-tool`) that eliminate duplicated matrix and step logic across build, lint, and test workflows.
- `ci-tiered-tests`: Tiered test strategy where PRs run a slim required matrix (Node.js + Chrome, common contexts) and the full browser/worker/ESM/atomics matrix runs on main pushes.
- `ci-coverage`: Simplified coverage pipeline — either containerised with a pre-built Docker image or replaced with `cargo-llvm-cov`, removing the custom `wasm-bindgen` fork dependency and `apt-key` usage.
- `ci-merge-queue`: GitHub Merge Queue configured on `main` with `merge_group` triggers on required workflows, replacing the custom `merge.yaml` workflow.
- `dev-tooling`: A `justfile` for local CI parity, weekly Dependabot, `cargo-hack` for feature combination testing, and tidied lint configuration with inline documentation.

### Modified Capabilities

<!-- No existing specs to modify — this is the first openspec changeset for this repo. -->

## Impact

- **CI workflows:** 10 files → ~7 files; total YAML lines reduced by 40–60%. All existing checks preserved.
- **Composite actions:** 3 new files under `.github/actions/`; 1 new reusable workflow `rust-ci.yml`.
- **Branch protection:** Merge queue requires admin configuration on the GitHub repo settings (not in code).
- **Docker:** Optional `Dockerfile.coverage` + scheduled rebuild workflow if containerisation is chosen for coverage.
- **Cargo.toml:** Version field updated; `[workspace.lints]` may be reorganised with comments (no lint-level changes).
- **CHANGELOG.md:** `[Unreleased]` section moved to `[2.0.0]`.
- **Dependabot:** `daily` → `weekly`.
- **merge.yaml:** Deleted, replaced by merge queue.
- **New root files:** `justfile`.
