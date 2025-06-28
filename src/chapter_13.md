# Chapter 13: Leptos Compilation Errors Reference

This comprehensive reference documents complex Leptos compilation errors for versions 0.6, 0.7, and 0.8, with specific focus on verbose WASM compilation issues that demonstrate the complexity of Leptos compared to other frameworks.

## Table of Contents

1. [Leptos 0.6 Errors](#leptos-06-errors)
2. [Leptos 0.7 Errors](#leptos-07-errors)
3. [WASM-Specific Errors](#wasm-specific-errors)
4. [Proc Macro Errors](#proc-macro-errors)
5. [Return Signature Mismatches](#return-signature-mismatches)
6. [General Troubleshooting](#general-troubleshooting)

---

## Leptos 0.6 Errors

### Server Function Return Type Mismatches

**Error:**

```
error[E0053]: method `from` has an incompatible type for trait
expected signature `fn(leptos::ServerFnError) -> MyAppError`
found signature `fn(MyAppError) -> leptos::ServerFnError<MyAppError>`
```

**Cause:** Type signature mismatch when implementing error handling traits.

**Solution:**

- Check your error type implementations
- Ensure proper trait bounds and return types match expected signatures

### WASM-Bindgen Version Conflicts

**Error:**

```
rust wasm file schema version: 0.2.84
this binary schema version: 0.2.86
```

**Cause:** Version mismatch between wasm-bindgen versions.

**Solution:**

```toml
# In Cargo.toml
wasm-bindgen = "=0.2.86"
```

---

## Leptos 0.7 Errors

### Match Arms Incompatible Types (Breaking Change)

**Error:**

```
error[E0308]: match arms have incompatible types
```

**Cause:** Leptos 0.7 introduced stricter type checking for view! macros in match expressions.

**Solution:**

```rust
// Option 1: Use Either
match condition {
    true => view! { <div>"Option A"</div> }.into_any(),
    false => view! { <span>"Option B"</span> }.into_any(),
}

// Option 2: Use EitherOf variants
match condition {
    Condition::A => Either::Left(view! { <div>"A"</div> }),
    Condition::B => Either::Right(view! { <span>"B"</span> }),
}
```

### Slow Compile Times

**Error:** Extremely slow compilation due to type system changes.

**Solution:**

```bash
# Development mode
RUSTFLAGS="--cfg erase_components" trunk serve
# or
RUSTFLAGS="--cfg erase_components" cargo leptos watch
```

**Note:** `--cfg=erase_components` is broken in tachys on 0.7.5

### Feature Configuration Issues

**Error:**

```
error: no method named render_to_string found for enum leptos::View
```

**Cause:** Incorrect feature flags in Cargo.toml.

**Solution:**

```toml
leptos = { version = "0.7", default-features = false, features = ["csr"] }
# or for SSR
leptos = { version = "0.7", default-features = false, features = ["ssr"] }
```

---

## WASM-Specific Errors

### Action Send Trait Issues

**Error:**

```
error: future cannot be sent between threads safely
```

**Cause:** Using `Action::new()` with reqwest in WASM environment.

**Solution:**

- Use WASM-compatible HTTP clients
- Ensure futures are `Send` when required

## Proc Macro Errors

### Proc Macro Panicked

**Error:**

```
error: proc macro panicked
```

**Cause:** rust-analyzer version incompatibility or macro expansion issues.

**Solution:**

```json
// In VSCode settings.json
{
  "rust-analyzer.procMacro.ignored": {
    "leptos_macro": ["server"]
  },
  "rust-analyzer.procMacro.enable": true
}
```

### Proc Macro Version Mismatch

**Error:**

```
proc-macro server's api version (3) is newer than rust-analyzer's (2)
```

**Solution:**

- Update rust-analyzer to latest version
- Use pre-release version if on latest stable Rust
- Ensure toolchain compatibility

---

## Return Signature Mismatches

### Conditional Return Types

**Error:**

```
error[E0308]: if and else have incompatible types
```

**Cause:** Different return types in conditional expressions.

**Solution:**

```rust
// Instead of:
let view = if condition {
    view! { <div>"A"</div> }
} else {
    view! { <span>"B"</span> }
};

// Use:
let view = if condition {
    view! { <div>"A"</div> }.into_any()
} else {
    view! { <span>"B"</span> }.into_any()
};
```

### Server Function Signatures

**Error:**

```
error[E0053]: method has an incompatible type for trait
```

**Solution:**

- Ensure proper `ServerFn` trait implementation
- Check error type conversions
- Verify async function signatures

---

## General Troubleshooting

### Debugging Commands

```bash
# Check macro expansion
cargo expand

# Debug with expectations
.expect("where it failed or why")

# Enable WASM stack traces
# Add to main.rs:
#[cfg(feature = "csr")]
console_error_panic_hook::set_once();
```

### Rust-Analyzer Troubleshooting

1. **Restart Server:** Click rust-analyzer in VSCode status bar → "Restart Server"
2. **Check Toolchain:** `rustc -V` (proc macro expansion requires rustc 1.64+)
3. **Disable Diagnostics:** Add `unresolved-proc-macro` to disabled diagnostics

## Migration Notes (0.6 → 0.7)

### Breaking Changes

1. **Type Erasure:** Match arms now require explicit type conversion
2. **Hydration Method:** Changed from ID-based to position-based
3. **Feature Flags:** Default features changed
4. **Tachys Renderer:** New rendering system with different performance characteristics

### Migration Checklist

- [ ] Update all leptos crates to 0.7
- [ ] Add `#![recursion_limit = "256"]` to workspace crates
- [ ] Convert match expressions to use `.into_any()` or `Either`
- [ ] Update feature flags in Cargo.toml
- [ ] Test hydration thoroughly
- [ ] Update rust-analyzer configuration

---

## Common Error Patterns

### Feature Configuration

```toml
# ❌ This causes issues
leptos = "0.7"

# ✅ This works
leptos = { version = "0.7", default-features = false, features = ["csr"] }
```

### WASM Dependencies

```toml
# ❌ This breaks WASM builds
[dependencies]
tokio = "1.0"

# ✅ This works
[dependencies]
tokio = { version = "1.0", optional = true }

[features]
ssr = ["tokio"]
```

---

## Resources

- [Leptos Book](https://book.leptos.dev/)
- [Leptos API Documentation](https://docs.rs/leptos/)
- [Leptos GitHub Issues](https://github.com/leptos-rs/leptos/issues)
- [Leptos Discord Community](https://discord.gg/leptos)
- [Rust-Analyzer Configuration](https://rust-analyzer.github.io/book/configuration)

---

_This reference is based on community reports and official documentation. Error patterns may vary depending on your specific setup and dependencies._
