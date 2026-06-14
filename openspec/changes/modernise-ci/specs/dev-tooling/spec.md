## ADDED Requirements

### Requirement: justfile exists with CI-mirroring recipes

A `justfile` SHALL exist at the repository root providing recipes that mirror CI checks: `fmt`, `fmt-check`, `lint`, `lint-doc`, `test-native`, `test-wasm`, `spellcheck`, `audit`, `build`, and a `check` recipe that runs all of the above.

#### Scenario: List available recipes
- **WHEN** `just --list` is executed
- **THEN** all CI-mirroring recipes are listed with descriptions

#### Scenario: Run all checks locally
- **WHEN** `just check` is executed
- **THEN** format checks, lint, native tests, spellcheck, and audit all run

### Requirement: Dependabot runs weekly

The `dependabot.yaml` configuration SHALL set `interval: weekly` for both the `cargo` and `github-actions` ecosystems.

#### Scenario: Dependabot configuration
- **WHEN** `.github/dependabot.yaml` is inspected
- **THEN** `schedule.interval` is `weekly` for both update groups
- **AND** Cargo dependencies are grouped under a single `cargo` group pattern

### Requirement: cargo-hack is available for feature testing

A `just hack` recipe SHALL run `cargo hack build --feature-powerset` (or equivalent) to validate all feature combinations compile.

#### Scenario: Test all feature combinations
- **WHEN** `just hack` is executed
- **THEN** `cargo hack` builds the crate with all valid feature combinations
- **AND** exits with status 0 if all combinations compile

### Requirement: Lint configuration is documented

The `[workspace.lints]` section in `Cargo.toml` SHALL include inline comments grouping lints by rationale (e.g., safety-critical, code clarity, project conventions).

#### Scenario: Lint config readability
- **WHEN** a contributor reads the `[workspace.lints]` section of `Cargo.toml`
- **THEN** comment lines explain the purpose of each lint group
