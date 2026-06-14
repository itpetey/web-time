# justfile — local CI parity commands for web-time
# Run `just --list` to see available recipes.

# Format all code with rustfmt.
fmt:
    cargo +nightly fmt
    tombi format
    prettier . --write

# Check formatting without modifying files.
fmt-check:
    cargo +nightly fmt --check
    tombi format --check
    prettier . --check

# Run Clippy on all targets with default features.
lint:
    cargo clippy --workspace --all-targets -- -D warnings

# Run rustdoc and check for documentation warnings.
lint-doc:
    RUSTDOCFLAGS="-D warnings" cargo doc --workspace --no-deps --document-private-items --lib --examples

# Run native tests.
test-native:
    cargo test --workspace

# Run Wasm tests in Chrome (requires chromedriver).
test-wasm:
    #!/usr/bin/env bash
    chromedriver --port=9000 &
    pid=$!
    WASM_BINDGEN_USE_BROWSER=1 CHROMEDRIVER_REMOTE=http://127.0.0.1:9000 \
        cargo test --workspace --target wasm32-unknown-unknown
    kill $pid

# Run spellcheck on source and documentation.
spellcheck:
    cargo spellcheck check -m 1
    cargo spellcheck check -m 1 CHANGELOG.md
    cargo spellcheck check -m 1 CONTRIBUTING.md

# Run cargo audit for security advisories.
audit:
    cargo audit -D warnings

# Build the crate for native and Wasm targets.
build:
    cargo build
    cargo build --target wasm32-unknown-unknown

# Run all CI checks locally.
check: fmt-check lint test-native spellcheck audit

# Test all feature combinations with cargo-hack.
hack:
    cargo hack build --feature-powerset
