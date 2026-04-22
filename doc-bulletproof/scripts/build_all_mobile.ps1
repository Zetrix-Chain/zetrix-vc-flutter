# Quick Build Script - Builds both iOS and Android libraries
# Usage: .\scripts\build_all_mobile.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 Building ALL Mobile Libraries (iOS + Android)" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\build_mobile_libs.ps1" -All

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 All libraries built successfully!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Build failed. Check errors above." -ForegroundColor Red
    exit 1
}
