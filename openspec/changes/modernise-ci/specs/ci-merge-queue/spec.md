## ADDED Requirements

### Requirement: Merge queue is enabled on main branch

GitHub Merge Queue SHALL be configured on the `main` branch such that merging requires passing CI checks via a `merge_group` event rather than a comment-triggered workflow.

#### Scenario: Merge queue trigger in required workflows
- **WHEN** a PR is added to the merge queue
- **THEN** required workflows (`build`, `test`, `lint`, `format`, `audit`) are triggered with `github.event_name == 'merge_group'`
- **AND** the merge group commit is validated against the base branch

#### Scenario: Successful merge queue run
- **WHEN** all required checks pass on the merge group
- **THEN** the PR is merged to `main` with a linear history (no merge commits)

### Requirement: Custom merge workflow is removed

The `merge.yaml` workflow file SHALL be deleted from the repository.

#### Scenario: merge.yaml does not exist
- **WHEN** the `.github/workflows/` directory is listed
- **THEN** `merge.yaml` is not present

### Requirement: Contributing guide reflects merge queue

`CONTRIBUTING.md` SHALL document the merge queue process, replacing any references to `/fast-forward-merge` comments.

#### Scenario: Contributing guide instructions
- **WHEN** a contributor reads `CONTRIBUTING.md`
- **THEN** the merge section describes adding PRs to the merge queue via the GitHub UI
- **AND** no reference to `/fast-forward-merge` comments remains
