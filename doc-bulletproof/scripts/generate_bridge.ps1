# Flutter Rust Bridge Code Generator
# Generates Dart FFI bindings from Rust code

Write-Host "=== Flutter Rust Bridge Code Generator ===" -ForegroundColor Cyan
Write-Host ""

# Check if flutter_rust_bridge_codegen is installed
Write-Host "Checking for flutter_rust_bridge_codegen..." -ForegroundColor Yellow
$frbInstalled = Get-Command flutter_rust_bridge_codegen -ErrorAction SilentlyContinue

if (-not $frbInstalled) {
    Write-Host "❌ flutter_rust_bridge_codegen not found!" -ForegroundColor Red
    Write-Host "Installing flutter_rust_bridge_codegen..." -ForegroundColor Yellow
    cargo install flutter_rust_bridge_codegen
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install flutter_rust_bridge_codegen" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✓ flutter_rust_bridge_codegen found" -ForegroundColor Green
Write-Host ""

# Generate bridge code
Write-Host "Generating bridge code..." -ForegroundColor Yellow
Write-Host "  Rust input:  crate::api" -ForegroundColor Gray
Write-Host "  Rust root:   rust" -ForegroundColor Gray
Write-Host "  Dart output: lib" -ForegroundColor Gray
Write-Host ""

flutter_rust_bridge_codegen generate `
    --rust-input crate::api `
    --rust-root rust `
    --dart-output lib

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Bridge generation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Bridge code generated successfully!" -ForegroundColor Green
Write-Host ""

# Format generated Dart code
Write-Host "Formatting Dart code..." -ForegroundColor Yellow
dart format lib\src\bridge_generated.dart

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Dart formatting failed (non-critical)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Generation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Build Rust library for your platform:" -ForegroundColor White
Write-Host "     - Android: cd rust && cargo ndk build --release" -ForegroundColor Gray
Write-Host "     - iOS: cd rust && cargo build --release --target aarch64-apple-ios" -ForegroundColor Gray
Write-Host "  2. Run tests: flutter test test\bulletproof_test.dart" -ForegroundColor White
Write-Host ""
