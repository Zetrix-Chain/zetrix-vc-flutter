# ============================================================================
# Mobile Libraries Build Script (iOS & Android)
# Compiles Rust bulletproof libraries for iOS and Android on Windows
# ============================================================================

param(
    [switch]$Android = $false,
    [switch]$iOS = $false,
    [switch]$All = $false,
    [switch]$SkipCopy = $false
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Header($msg) { Write-Host "`n$msg" -ForegroundColor Cyan -BackgroundColor Black }
function Write-Success($msg) { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warning2($msg) { Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "ℹ️  $msg" -ForegroundColor Blue }
function Write-Error2($msg) { Write-Host "❌ $msg" -ForegroundColor Red }

# ============================================================================
# Configuration
# ============================================================================

$projectRoot = Split-Path $PSScriptRoot -Parent
$rustRoot = Join-Path $projectRoot "rust"
$androidJniLibs = Join-Path $projectRoot "android\src\main\jniLibs"
$iosFrameworks = Join-Path $projectRoot "ios\Frameworks"

Write-Header "🚀 Mobile Libraries Build Script"
Write-Host "Project: $projectRoot" -ForegroundColor Gray

# ============================================================================
# Check Prerequisites
# ============================================================================

Write-Header "🔍 Checking Prerequisites..."

# Check Rust
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Error2 "Rust/Cargo not found. Install from: https://rustup.rs/"
    exit 1
}
Write-Success "Rust/Cargo installed: $(cargo --version)"

# Check cargo-ndk
if (-not (Get-Command cargo-ndk -ErrorAction SilentlyContinue)) {
    Write-Warning2 "cargo-ndk not found (required for Android)"
    Write-Info "Install with: cargo install cargo-ndk"
    $hasCargoNdk = $false
} else {
    Write-Success "cargo-ndk installed: $(cargo-ndk --version)"
    $hasCargoNdk = $true
}

# Check Android NDK
if ($env:ANDROID_NDK_HOME) {
    if (Test-Path $env:ANDROID_NDK_HOME) {
        Write-Success "Android NDK: $env:ANDROID_NDK_HOME"
        $hasNdk = $true
    } else {
        Write-Warning2 "ANDROID_NDK_HOME set but path doesn't exist"
        $hasNdk = $false
    }
} elseif ($env:ANDROID_HOME) {
    $ndkPath = Get-ChildItem -Path "$env:ANDROID_HOME\ndk" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ndkPath) {
        $env:ANDROID_NDK_HOME = $ndkPath.FullName
        Write-Success "Android NDK found: $env:ANDROID_NDK_HOME"
        $hasNdk = $true
    } else {
        Write-Warning2 "Android NDK not found in ANDROID_HOME"
        $hasNdk = $false
    }
} else {
    Write-Warning2 "Android NDK not configured"
    Write-Info "Set ANDROID_NDK_HOME or install via Android Studio SDK Manager"
    $hasNdk = $false
}

# Determine what to build
if ($All) {
    $buildAndroid = $hasNdk -and $hasCargoNdk
    $buildiOS = $true
} else {
    if ($Android) {
        if (-not $hasNdk -or -not $hasCargoNdk) {
            Write-Error2 "Cannot build Android: NDK and cargo-ndk required"
            exit 1
        }
        $buildAndroid = $true
        $buildiOS = $false
    } elseif ($iOS) {
        $buildAndroid = $false
        $buildiOS = $true
    } else {
        # Default: build what's available
        $buildAndroid = $hasNdk -and $hasCargoNdk
        $buildiOS = $true
    }
}

Write-Host "`nBuild Plan:" -ForegroundColor Cyan
Write-Host "  Android: $buildAndroid" -ForegroundColor $(if ($buildAndroid) { "Green" } else { "Gray" })
Write-Host "  iOS: $buildiOS" -ForegroundColor $(if ($buildiOS) { "Green" } else { "Gray" })

if (-not $buildAndroid -and -not $buildiOS) {
    Write-Error2 "Nothing to build. Check prerequisites or use -All flag"
    exit 1
}

# ============================================================================
# Check/Install Rust Targets
# ============================================================================

Write-Header "🎯 Checking Rust Targets..."

$requiredTargets = @()
if ($buildAndroid) {
    $requiredTargets += @(
        "aarch64-linux-android",
        "armv7-linux-androideabi",
        "x86_64-linux-android",
        "i686-linux-android"
    )
}
if ($buildiOS) {
    $requiredTargets += @(
        "aarch64-apple-ios",
        "aarch64-apple-ios-sim",
        "x86_64-apple-ios"
    )
}

$installedTargets = rustup target list --installed
$missingTargets = @()

foreach ($target in $requiredTargets) {
    if ($installedTargets -match [regex]::Escape($target)) {
        Write-Host "  ✓ $target" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $target (will install)" -ForegroundColor Yellow
        $missingTargets += $target
    }
}

if ($missingTargets.Count -gt 0) {
    Write-Info "Installing missing targets..."
    foreach ($target in $missingTargets) {
        Write-Host "  Installing $target..." -ForegroundColor Yellow
        rustup target add $target
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Failed to install target: $target"
            exit 1
        }
    }
    Write-Success "All targets installed"
}

# ============================================================================
# Build Android Libraries
# ============================================================================

if ($buildAndroid) {
    Write-Header "🤖 Building Android Libraries..."
    
    Push-Location $rustRoot
    
    try {
        $androidTargets = @(
            "aarch64-linux-android",      # ARM64
            "armv7-linux-androideabi",    # ARM32
            "x86_64-linux-android",       # x86_64 emulator
            "i686-linux-android"          # x86 emulator
        )
        
        Write-Info "Building for Android architectures..."
        $targetArgs = $androidTargets | ForEach-Object { "--target"; $_ }
        
        & cargo ndk @targetArgs build --release
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Android build failed"
            Pop-Location
            exit 1
        }
        
        Write-Success "Android libraries compiled"
        
        # Copy libraries
        if (-not $SkipCopy) {
            Write-Info "Copying Android libraries..."
            
            $androidLibs = @{
                "aarch64-linux-android" = "arm64-v8a"
                "armv7-linux-androideabi" = "armeabi-v7a"
                "x86_64-linux-android" = "x86_64"
                "i686-linux-android" = "x86"
            }
            
            foreach ($target in $androidLibs.Keys) {
                $abi = $androidLibs[$target]
                $srcPath = Join-Path $rustRoot "target\$target\release\libbulletproof.so"
                $dstDir = Join-Path $androidJniLibs $abi
                $dstPath = Join-Path $dstDir "libbulletproof.so"
                
                if (Test-Path $srcPath) {
                    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
                    Copy-Item $srcPath $dstPath -Force
                    $size = [math]::Round((Get-Item $dstPath).Length / 1MB, 2)
                    Write-Host "    $abi ($size MB)" -ForegroundColor Green
                } else {
                    Write-Warning2 "Library not found: $srcPath"
                }
            }
            
            Write-Success "Android libraries copied to: $androidJniLibs"
        }
        
    } finally {
        Pop-Location
    }
}

# ============================================================================
# Build iOS Libraries
# ============================================================================

if ($buildiOS) {
    Write-Header "🍎 Building iOS Libraries..."
    Write-Warning2 "iOS builds require macOS SDK and Xcode (not available on Windows)"
    Write-Info "This will attempt to build, but will likely fail..."
    
    Push-Location $rustRoot
    
    $iosBuildSuccess = $false
    
    try {
        $iosTargets = @(
            "aarch64-apple-ios",          # iPhone/iPad device
            "aarch64-apple-ios-sim",      # Simulator (Apple Silicon)
            "x86_64-apple-ios"            # Simulator (Intel)
        )
        
        foreach ($target in $iosTargets) {
            Write-Info "Attempting to build $target..."
            
            cargo build --release --target $target 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                $libPath = Join-Path $rustRoot "target\$target\release\libbulletproof.a"
                if (Test-Path $libPath) {
                    $size = [math]::Round((Get-Item $libPath).Length / 1MB, 2)
                    Write-Host "    ✓ $target ($size MB)" -ForegroundColor Green
                    $iosBuildSuccess = $true
                }
            }
        }
        
        if (-not $iosBuildSuccess) {
            Write-Header "⚠️ iOS Build Failed (Expected on Windows)"
            Write-Host ""
            Write-Host "iOS builds require:" -ForegroundColor Yellow
            Write-Host "  • macOS with Xcode Command Line Tools" -ForegroundColor Gray
            Write-Host "  • Apple's clang compiler with iOS SDK" -ForegroundColor Gray
            Write-Host "  • xcrun tool (part of Xcode)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "✅ Solutions:" -ForegroundColor Cyan
            Write-Host "  1. Use GitHub Actions (FREE) - See MOBILE_BUILD_GUIDE.md" -ForegroundColor White
            Write-Host "  2. Use cloud Mac service (MacinCloud, AWS EC2 Mac)" -ForegroundColor White
            Write-Host "  3. Build on physical Mac" -ForegroundColor White
            Write-Host ""
            Write-Host "📖 For GitHub Actions setup:" -ForegroundColor Cyan
            Write-Host "   See: MOBILE_BUILD_GUIDE.md (GitHub Actions section)" -ForegroundColor White
            Write-Host ""
            
            # Don't try to copy if build failed
            Pop-Location
            
            # Update flag so summary reflects reality
            $buildiOS = $false
            return
        }
        
        # Copy libraries (only if build succeeded)
        if (-not $SkipCopy -and $iosBuildSuccess) {
            Write-Info "Copying iOS libraries..."
            
            New-Item -ItemType Directory -Force -Path $iosFrameworks | Out-Null
            
            # Copy device library (primary)
            $deviceLib = Join-Path $rustRoot "target\aarch64-apple-ios\release\libbulletproof.a"
            if (Test-Path $deviceLib) {
                $dstPath = Join-Path $iosFrameworks "libbulletproof.a"
                Copy-Item $deviceLib $dstPath -Force
                $size = [math]::Round((Get-Item $dstPath).Length / 1MB, 2)
                Write-Success "Device library ($size MB): $dstPath"
            }
            
            # Copy simulator libraries
            $simArmLib = Join-Path $rustRoot "target\aarch64-apple-ios-sim\release\libbulletproof.a"
            if (Test-Path $simArmLib) {
                $dstPath = Join-Path $iosFrameworks "libbulletproof_sim_arm64.a"
                Copy-Item $simArmLib $dstPath -Force
                Write-Host "    Simulator ARM64: $dstPath" -ForegroundColor Green
            }
            
            $simX64Lib = Join-Path $rustRoot "target\x86_64-apple-ios\release\libbulletproof.a"
            if (Test-Path $simX64Lib) {
                $dstPath = Join-Path $iosFrameworks "libbulletproof_sim_x64.a"
                Copy-Item $simX64Lib $dstPath -Force
                Write-Host "    Simulator x86_64: $dstPath" -ForegroundColor Green
            }
            
            Write-Success "iOS libraries copied to: $iosFrameworks"
        }
        
    } finally {
        Pop-Location
    }
}

# ============================================================================
# Summary
# ============================================================================

Write-Header "📊 Build Summary"

if ($buildAndroid) {
    Write-Host "`n✅ Android Libraries:" -ForegroundColor Green
    Write-Host "   Location: $androidJniLibs" -ForegroundColor Gray
    Write-Host "   Architectures: ARM64, ARM32, x86_64, x86" -ForegroundColor Gray
    Write-Host "   Next: flutter build apk --release" -ForegroundColor Yellow
}

if ($buildiOS) {
    Write-Host "`n✅ iOS Libraries:" -ForegroundColor Green
    Write-Host "   Location: $iosFrameworks" -ForegroundColor Gray
    Write-Host "   Targets: Device (ARM64), Simulator (ARM64, x86_64)" -ForegroundColor Gray
    Write-Host "   Note: Final .ipa build requires macOS + Xcode or CI/CD" -ForegroundColor Yellow
}

Write-Host "`n🎯 Bulletproof functionality included in all builds" -ForegroundColor Cyan

Write-Header "✅ Build Complete!"

# ============================================================================
# Verification
# ============================================================================

Write-Host "`n💡 Verification Commands:" -ForegroundColor Cyan

if ($buildAndroid) {
    Write-Host "  # Verify Android libs" -ForegroundColor Gray
    Write-Host "  ls $androidJniLibs\**\*.so" -ForegroundColor White
    Write-Host "`n  # Build APK" -ForegroundColor Gray
    Write-Host "  flutter build apk --release" -ForegroundColor White
}

if ($buildiOS) {
    Write-Host "`n  # Verify iOS libs" -ForegroundColor Gray
    Write-Host "  ls $iosFrameworks\*.a" -ForegroundColor White
}

Write-Host ""
