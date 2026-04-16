# Build script for Android
# Make sure to set ANDROID_NDK_HOME before running this script

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Zetrix VC Flutter - Android Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify NDK installation
if (-not $env:ANDROID_NDK_HOME) {
    Write-Host "❌ Error: ANDROID_NDK_HOME not set" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Android NDK and set the environment variable:" -ForegroundColor Yellow
    Write-Host '  $env:ANDROID_NDK_HOME = "$env:ANDROID_HOME\ndk\<version>"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "See MOBILE_BUILD_GUIDE.md for installation instructions" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ NDK found: $env:ANDROID_NDK_HOME" -ForegroundColor Green
Write-Host ""

# Build Rust libraries
Write-Host "Building Rust libraries for Android..." -ForegroundColor Green
Write-Host "This may take 5-10 minutes on first build..." -ForegroundColor Yellow
Write-Host ""

Push-Location rust

try {
    # Set 16KB page size linker flag (required for Android 15+ / Google Play)
    # Backwards-compatible with 4KB-page devices
    $env:RUSTFLAGS = "-C link-arg=-Wl,-z,max-page-size=16384"
    Write-Host "✓ RUSTFLAGS set: $env:RUSTFLAGS" -ForegroundColor Green
    Write-Host ""

    cargo ndk `
        --target aarch64-linux-android `
        --target armv7-linux-androideabi `
        --target x86_64-linux-android `
        --target i686-linux-android `
        build --release

    if ($LASTEXITCODE -ne 0) {
        throw "Rust build failed"
    }

    Write-Host ""
    Write-Host "✓ Rust libraries built successfully" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "❌ Build failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# Create JNI directories
Write-Host "Preparing JNI library folders..." -ForegroundColor Green
$jniLibs = "android\src\main\jniLibs"
New-Item -ItemType Directory -Force -Path "$jniLibs\arm64-v8a" | Out-Null
New-Item -ItemType Directory -Force -Path "$jniLibs\armeabi-v7a" | Out-Null
New-Item -ItemType Directory -Force -Path "$jniLibs\x86_64" | Out-Null
New-Item -ItemType Directory -Force -Path "$jniLibs\x86" | Out-Null

# Copy libraries
Write-Host "Copying native libraries..." -ForegroundColor Green

$libs = @(
    @{src="rust\target\aarch64-linux-android\release\libbulletproof.so"; dst="$jniLibs\arm64-v8a\"; arch="ARM64"},
    @{src="rust\target\armv7-linux-androideabi\release\libbulletproof.so"; dst="$jniLibs\armeabi-v7a\"; arch="ARM32"},
    @{src="rust\target\x86_64-linux-android\release\libbulletproof.so"; dst="$jniLibs\x86_64\"; arch="x86_64"},
    @{src="rust\target\i686-linux-android\release\libbulletproof.so"; dst="$jniLibs\x86\"; arch="x86"}
)

foreach ($lib in $libs) {
    if (Test-Path $lib.src) {
        Copy-Item $lib.src $lib.dst -Force
        $size = (Get-Item $lib.src).Length / 1MB
        Write-Host "  ✓ $($lib.arch) - $([math]::Round($size, 2)) MB" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ $($lib.arch) library not found (skipping)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✓ Libraries copied to jniLibs/" -ForegroundColor Green
Write-Host ""

# Build Flutter APK
Write-Host "Building Flutter APK..." -ForegroundColor Green
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ APK build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ✅ Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "APK Location:" -ForegroundColor Yellow
Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "Install on device:" -ForegroundColor Yellow
Write-Host "  flutter install" -ForegroundColor White
Write-Host ""
Write-Host "Or run directly:" -ForegroundColor Yellow
Write-Host "  cd example" -ForegroundColor White
Write-Host "  flutter run -d <device-id>" -ForegroundColor White
Write-Host ""
