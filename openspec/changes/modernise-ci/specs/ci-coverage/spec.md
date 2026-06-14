## ADDED Requirements

### Requirement: Coverage workflow uses no deprecated apt-key pattern

The coverage workflow SHALL NOT use `wget` piped to `apt-key add` for installing Clang or any other dependency.

#### Scenario: Coverage workflow inspection
- **WHEN** the coverage workflow file is inspected
- **THEN** no step contains `apt-key add`
- **AND** Clang installation uses either a pre-built Docker image or a supported `apt` signed-by pattern

### Requirement: Custom wasm-bindgen fork is removed or documented

If the custom `wasm-bindgen` fork (`daxpedda/wasm-bindgen` at `d4cb4a5`) is still required, the workflow SHALL document the reason with a link to the upstream tracking issue. If the feature has been upstreamed, the workflow SHALL use the published `wasm-bindgen-cli` from crates.io.

#### Scenario: Fork is still needed
- **WHEN** the coverage workflow installs `wasm-bindgen-cli` from a git source
- **THEN** a comment in the workflow explains why the fork is required
- **AND** a link to the upstream PR or issue is present

#### Scenario: Fork is no longer needed
- **WHEN** the fix has been upstreamed
- **THEN** `wasm-bindgen-cli` is installed via `taiki-e/install-action` with a version from crates.io

### Requirement: Coverage HTML and JSON reports are generated

The coverage workflow SHALL produce an HTML report and a `coverage.json` file with the coverage percentage, identical in format to the current output.

#### Scenario: Coverage artifacts uploaded
- **WHEN** the coverage workflow completes successfully
- **THEN** an artifact named `test-coverage` is uploaded containing `index.html` and `coverage.json`
- **AND** `coverage.json` contains a `coverage` field with a percentage string

### Requirement: Coverage percentage is not reduced

The coverage percentage reported after the refactoring SHALL be equal to or greater than the coverage percentage before the refactoring.

#### Scenario: Coverage comparison
- **WHEN** the new coverage workflow runs on the same commit as the old workflow
- **THEN** the reported coverage percentage is >= the old reported coverage percentage
