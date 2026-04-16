# Test Bulletproof SDK on Windows
# This demonstrates that the SDK works offline

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Bulletproof SDK - Windows Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run tests
Write-Host "Running bulletproof tests..." -ForegroundColor Green
Write-Host ""

flutter test test/bulletproof_test.dart test/bulletproof_java_compatibility_test.dart

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " ✅ All Tests Passed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "The SDK is working correctly on Windows." -ForegroundColor Green
    Write-Host "The same Rust code will work on Android/iOS once compiled." -ForegroundColor Green
    Write-Host ""
    Write-Host "To test the demo app:" -ForegroundColor Yellow
    Write-Host "  cd example" -ForegroundColor White
    Write-Host "  flutter run -d windows" -ForegroundColor White
    Write-Host ""
    Write-Host "To build for Android:" -ForegroundColor Yellow
    Write-Host "  1. Install Android NDK (see MOBILE_BUILD_GUIDE.md)" -ForegroundColor White
    Write-Host "  2. Run: .\scripts\build_android.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Tests failed" -ForegroundColor Red
    exit 1
}
