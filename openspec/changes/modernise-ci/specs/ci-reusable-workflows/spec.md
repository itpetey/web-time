## ADDED Requirements

### Requirement: Composite action for Rust setup exists

A composite action SHALL exist at `.github/actions/setup-rust/action.yml` that accepts `toolchain`, `target`, `components`, and `default` inputs and performs checkout, Rust toolchain installation, and default setting.

#### Scenario: Install stable Rust for native target
- **WHEN** called with `toolchain: stable`, `target: x86_64-unknown-linux-gnu`, `default: true`
- **THEN** `rustup toolchain install stable --profile minimal --target x86_64-unknown-linux-gnu` is executed
- **AND** `rustup default stable` is executed

#### Scenario: Install nightly Rust with extra components
- **WHEN** called with `toolchain: nightly`, `target: wasm32-unknown-unknown`, `components: clippy,rust-src`
- **THEN** `rustup toolchain install nightly --profile minimal --component clippy --component rust-src --target wasm32-unknown-unknown` is executed

### Requirement: Composite action for Wasm build environment exists

A composite action SHALL exist at `.github/actions/setup-wasm/action.yml` that accepts `cflags`, `rustflags`, `build-std`, and `no-std` inputs and exports the appropriate environment variables (`CFLAGS_*`, `CARGO_TARGET_*_RUSTFLAGS`, `BUILD_STD_COMPONENTS`).

#### Scenario: Set build-std for std target
- **WHEN** called with `build-std: true`, `no-std: false`
- **THEN** `BUILD_STD_COMPONENTS` is set to `-Zbuild-std=panic_abort,std`

#### Scenario: Set build-std for no_std target
- **WHEN** called with `build-std: true`, `no-std: true`
- **THEN** `BUILD_STD_COMPONENTS` is set to `-Zbuild-std=core,alloc`

#### Scenario: Set atomics CFLAGS and RUSTFLAGS
- **WHEN** called with `cflags: -matomics -mbulk-memory`, `rustflags: -Ctarget-feature=+atomics,+bulk-memory`
- **THEN** `CFLAGS_wasm32_unknown_unknown` is set to `-matomics -mbulk-memory`
- **AND** `CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_RUSTFLAGS` is set to `-Ctarget-feature=+atomics,+bulk-memory`

### Requirement: Composite action for tool installation exists

A composite action SHALL exist at `.github/actions/setup-tool/action.yml` that accepts a `tool` input and installs it via `taiki-e/install-action`.

#### Scenario: Install wasm-bindgen-cli
- **WHEN** called with `tool: wasm-bindgen-cli`
- **THEN** `taiki-e/install-action@v2` is invoked with `tool: wasm-bindgen-cli`

### Requirement: Reusable CI workflow exists

A reusable workflow SHALL exist at `.github/workflows/rust-ci.yml` that accepts `command`, `target`, `toolchain`, `features`, `cflags`, `rustflags`, `build-std`, `no-std`, and `working-directory` inputs, and executes the specified cargo command with the given configuration.

#### Scenario: Build with default features
- **WHEN** called with `command: build`, `target: wasm32-unknown-unknown`, `toolchain: stable`, `features: ""`
- **THEN** `cargo build --target wasm32-unknown-unknown` is executed successfully

#### Scenario: Clippy with no_std and msrv features
- **WHEN** called with `command: clippy`, `target: wasm32-unknown-unknown`, `toolchain: nightly`, `features: --no-default-features --features msrv`, `build-std: true`, `no-std: true`
- **THEN** `cargo clippy --workspace --all-targets --no-default-features --features msrv --target wasm32-unknown-unknown -Zbuild-std=core,alloc -- -D warnings` is executed

#### Scenario: Doc generation with docsrs cfg
- **WHEN** called with `command: doc`, `target: wasm32-unknown-unknown`, `toolchain: nightly`, `features: --features serde`, `rustflags: --cfg=docsrs`
- **THEN** `cargo doc --workspace --no-deps --document-private-items --lib --examples --features serde --target wasm32-unknown-unknown` is executed with `RUSTDOCFLAGS` including `--cfg=docsrs`

### Requirement: Caller workflows delegate to reusable workflow

The `build.yaml`, `lint.yaml`, `audit.yaml`, `format.yaml`, `test.yaml`, `publish.yaml`, and `coverage-documentation.yaml` workflows SHALL use the composite actions and/or reusable workflow for all step sequences that were previously duplicated.

#### Scenario: build.yaml uses rust-ci reusable workflow
- **WHEN** `build.yaml` is inspected
- **THEN** its job steps call `uses: ./.github/workflows/rust-ci.yml` with matrix parameters
- **AND** it does not contain inline "Install Rust" or "Set build-std components" steps

#### Scenario: format.yaml uses setup-rust and setup-tool
- **WHEN** `format.yaml` is inspected
- **THEN** its job steps call `uses: ./.github/actions/setup-rust` and `uses: ./.github/actions/setup-tool`
- **AND** it does not contain inline `rustup` or `taiki-e/install-action` invocations
