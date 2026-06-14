## ADDED Requirements

### Requirement: Required test tier runs on PRs

A `test` job SHALL run on every PR push and SHALL cover the essential test combinations: Node.js with default and no_std features, Chrome with Browser and Dedicated Worker contexts, and native (x86_64) stable.

#### Scenario: PR triggers required tests only
- **WHEN** a pull request is opened or updated
- **THEN** the `test` workflow runs jobs for Node.js + Chrome + native combinations
- **AND** no Firefox, Safari, Service Worker, Shared Worker, ESM, or atomics jobs are triggered

#### Scenario: Required tests pass before merge
- **WHEN** all required `test` jobs complete successfully
- **THEN** the PR's required status checks are green

### Requirement: Optional test tier runs on main pushes

A `test-extra` job SHALL run on every push to `main` and SHALL cover the full test matrix including Firefox, Safari, Shared Worker, Service Worker, ESM, and atomics variants.

#### Scenario: Main push triggers full test matrix
- **WHEN** a commit is pushed to `main`
- **THEN** the `test-extra` workflow runs all browser/driver combinations (Chrome, Firefox, Safari, Node.js)
- **AND** all execution contexts (Browser, Dedicated Worker, Shared Worker, Service Worker, ESM, no-modules)
- **AND** atomics variants are tested

#### Scenario: Optional tests do not block PRs
- **WHEN** a pull request is evaluated for merge
- **THEN** the `test-extra` job status is NOT among the required status checks

### Requirement: No test coverage is lost

Every test combination that passed before the split SHALL still run somewhere — either in `test` or `test-extra`.

#### Scenario: Full coverage audit
- **WHEN** the union of `test` and `test-extra` matrices is compared to the original `test` matrix
- **THEN** no driver × environment × feature × Rust version combination is absent from both tiers
