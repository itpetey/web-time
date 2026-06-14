## ADDED Requirements

### Requirement: Crate version is 2.0.0

The crate version in `Cargo.toml` SHALL be `2.0.0`, reflecting the breaking changes since 1.1.0 (new default features `std` and `msrv`, `wasm32v1-none` target support, MSRV raised to 1.87).

#### Scenario: Version field in Cargo.toml
- **WHEN** a maintainer reads `Cargo.toml`
- **THEN** the `version` field is `"2.0.0"`

#### Scenario: Dry-run publish succeeds
- **WHEN** `cargo publish --dry-run` is executed
- **THEN** the command exits with status 0 and reports the package as publishable

### Requirement: Changelog reflects the 2.0.0 release

The `CHANGELOG.md` SHALL contain a `[2.0.0]` section documenting all features listed in the current `[Unreleased]` section, with a release date.

#### Scenario: Changelog has 2.0.0 section
- **WHEN** a maintainer reads `CHANGELOG.md`
- **THEN** a `## [2.0.0] - YYYY-MM-DD` section exists containing the `no_std`, `wasm32v1-none`, and `msrv` feature entries
- **AND** the `[Unreleased]` section is empty or contains only post-2.0.0 changes

#### Scenario: Comparison links are updated
- **WHEN** a maintainer scrolls to the bottom of `CHANGELOG.md`
- **THEN** a `[2.0.0]` comparison link exists pointing to `v1.1.0...v2.0.0`
- **AND** the `[Unreleased]` link points to `v2.0.0...HEAD`
