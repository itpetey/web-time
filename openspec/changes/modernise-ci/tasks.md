## 1. Version Management (Phase 1)

- [x] 1.1 Update `version` field in `Cargo.toml` from `1.1.0` to `2.0.0`
- [x] 1.2 Move `[Unreleased]` content in `CHANGELOG.md` to a new `## [2.0.0] - YYYY-MM-DD` section
- [x] 1.3 Add `[2.0.0]` comparison link at the bottom of `CHANGELOG.md` (`v1.1.0...v2.0.0`)
- [x] 1.4 Update `[Unreleased]` comparison link to `v2.0.0...HEAD`
- [x] 1.5 Run `cargo publish --dry-run` and verify exit code 0

## 2. Tiered Test Strategy (Phase 1)

- [x] 2.1 Split `test.yaml` into two jobs: `test` (required, PRs) and `test-extra` (optional, main-only)
- [x] 2.2 Define the `test` matrix: Node.js × {default, no_std}, Chrome × {Browser, Dedicated Worker} × {default, no_std}, plus native stable
- [x] 2.3 Define the `test-extra` matrix: all previously existing combinations not in the `test` tier
- [x] 2.4 Add `if: github.ref_name == 'main'` condition to `test-extra` job
- [x] 2.5 Verify no driver × environment × feature × Rust version combination is absent from the union of both tiers
- [ ] 2.6 Run both tiers on a test branch to confirm identical pass/fail behaviour

## 3. Composite Actions (Phase 2)

- [x] 3.1 Create `.github/actions/setup-rust/action.yml` with inputs: `toolchain`, `target`, `components`, `default`
- [x] 3.2 Create `.github/actions/setup-wasm/action.yml` with inputs: `cflags`, `rustflags`, `build-std`, `no-std`
- [x] 3.3 Create `.github/actions/setup-tool/action.yml` with input: `tool`
- [x] 3.4 Verify each composite action runs independently in a test workflow

## 4. Reusable Workflow (Phase 2)

- [x] 4.1 Create `.github/workflows/rust-ci.yml` as a reusable workflow (`workflow_call` trigger) accepting: `command`, `target`, `toolchain`, `features`, `cflags`, `rustflags`, `build-std`, `no-std`, `working-directory`
- [x] 4.2 Wire `setup-rust` and `setup-wasm` into `rust-ci.yml` with conditional logic for `build-std` and `no-std`
- [x] 4.3 Implement the `command` dispatch: `build`, `clippy`, `doc`, `test` invoking the correct cargo subcommand

## 5. Refactor Caller Workflows (Phase 2)

- [x] 5.1 Refactor `build.yaml` — replace inline steps with calls to `rust-ci.yml`; preserve all matrix combinations
- [x] 5.2 Refactor `lint.yaml` `clippy` job — replace inline steps with `rust-ci.yml` call
- [x] 5.3 Refactor `lint.yaml` `rustdoc` job — replace inline steps with `rust-ci.yml` call
- [x] 5.4 Refactor `test.yaml` — wire in `setup-rust`, `setup-wasm`, and `setup-tool`; keep the browser-driver and environment logic inline
- [x] 5.5 Refactor `format.yaml` — wire in `setup-rust` and `setup-tool`
- [x] 5.6 Refactor `audit.yaml` — wire in `setup-tool`
- [x] 5.7 Refactor `publish.yaml` — wire in `setup-rust`
- [x] 5.8 Diff the CI job list before and after refactoring to confirm zero lost matrix combinations
- [x] 5.9 Measure total YAML line reduction across all workflow files

## 6. Coverage Pipeline Simplification (Phase 3)

- [x] 6.1 Investigate: does the custom `wasm-bindgen` fork (`daxpedda/wasm-bindgen` at `d4cb4a5`) have an upstream PR? Document findings
- [x] 6.2 Investigate: does `cargo-llvm-cov` support `wasm32-unknown-unknown` with `wasm-bindgen-test` + `-Cinstrument-coverage`? Run a 15-minute spike
- [ ] 6.3 If `cargo-llvm-cov` works: replace the manual profraw/profdata pipeline with `cargo llvm-cov`
- [ ] 6.4 If `cargo-llvm-cov` does not work: create `Dockerfile.coverage` with Clang 19, `wasm-bindgen-cli`, `cargo-binutils`, and `chromedriver` pre-installed
- [ ] 6.5 If containerising: add a scheduled workflow to rebuild and push the coverage Docker image weekly
- [x] 6.6 Remove the `wget | apt-key add` pattern from the coverage workflow
- [x] 6.7 If the custom fork is still needed: add a comment in the workflow explaining why, with a link to the upstream issue
- [ ] 6.8 If the fork is no longer needed: switch to `wasm-bindgen-cli` from crates.io via `taiki-e/install-action`
- [x] 6.9 Wire `setup-rust` and `setup-wasm` composite actions into the coverage workflow
- [ ] 6.10 Verify coverage HTML and JSON output matches or exceeds the current coverage percentage

## 7. Merge Queue (Phase 3)

- [x] 7.1 Add `merge_group` trigger to required workflows: `build.yaml`, `test.yaml`, `lint.yaml`, `format.yaml`, `audit.yaml`
- [ ] 7.2 Coordinate with repo owner to enable merge queue in branch protection settings for `main`
- [ ] 7.3 Test merge queue with a small PR to confirm linear history enforcement
- [x] 7.4 Delete `merge.yaml`
- [x] 7.5 Update `CONTRIBUTING.md` — replace `/fast-forward-merge` instructions with merge queue UI instructions
- [x] 7.6 Remove `modernise` branch from all workflow `on.push.branches` triggers

## 8. Dev Tooling (Phase 4)

- [x] 8.1 Create `justfile` at repository root with recipes: `fmt`, `fmt-check`, `lint`, `lint-doc`, `test-native`, `test-wasm`, `spellcheck`, `audit`, `build`, `check`, `hack`
- [x] 8.2 Add `just hack` recipe using `cargo hack build --feature-powerset` to test all feature combinations
- [x] 8.3 Verify `just check` runs fmt-check + lint + test-native + spellcheck + audit without errors
- [ ] 8.4 Verify `just test-wasm` runs Wasm tests in Chrome (when chromedriver is available)
- [x] 8.5 Update `dependabot.yaml`: change `interval` to `weekly` for both ecosystems, add `groups` for Cargo and GitHub Actions
- [x] 8.6 Add inline comments to `[workspace.lints]` section in `Cargo.toml` grouping lints by rationale
- [x] 8.7 Move applicable Clippy settings from `Cargo.toml` to `clippy.toml` where supported
- [x] 8.8 Add a format comment at the top of `.config/topic.dic` explaining how to add new spellcheck terms

## 9. Final Verification

- [ ] 9.1 Run all CI workflows on a PR to confirm every check passes
- [ ] 9.2 Push to `main` and confirm `test-extra` and coverage workflows run
- [ ] 9.3 Confirm merge queue merges a PR with linear history
- [ ] 9.4 Review total workflow file count and YAML line count against baseline
