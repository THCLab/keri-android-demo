# `native/native.xcodeproj`

This is the Xcode project folder for the Rust native library generated by [`cargo-xcode`](https://lib.rs/crates/cargo-xcode).
The iOS and MacOS root projects import this folder as a *subproject* and depends on it during
build-time.

It is important that the suitable `crate-type`s are configured for your target devices.
Make sure these lines exist in your `Cargo.toml`:

```toml
[lib]
crate-type = ["lib", "cdylib", "staticlib"]
```

where
- `lib` is required for non-library targets, such as tests and benchmarks
- `staticlib` is required for iOS
- `cdylib` for all other platforms
