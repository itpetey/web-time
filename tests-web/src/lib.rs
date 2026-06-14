//! A crate for running tests on Web without the default test harness.

#![cfg_attr(all(target_arch = "wasm32", not(feature = "std")), no_std)]
#![cfg_attr(all(test, target_arch = "wasm32"), no_main)]

#[cfg(all(target_arch = "wasm32", not(feature = "std")))]
use wasm_bindgen_test as _;

#[cfg(all(test, not(target_arch = "wasm32")))]
fn main() {}

#[cfg(all(target_arch = "wasm32", not(feature = "std")))]
#[global_allocator]
static ALLOC: dlmalloc::GlobalDlmalloc = dlmalloc::GlobalDlmalloc;
