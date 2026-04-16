# 🔧 Build Scripts

Automated scripts for building mobile libraries.

## Available Scripts

### `build_mobile_libs.ps1` - Main Build Script

Comprehensive script for building iOS and Android libraries.

**Usage**:
```powershell
# Build both platforms (if prerequisites available)
.\scripts\build_mobile_libs.ps1 -All

# Android only
.\scripts\build_mobile_libs.ps1 -Android

# iOS only (will show alternatives if on Windows)
.\scripts\build_mobile_libs.ps1 -iOS

# Skip copying files
.\scripts\build_mobile_libs.ps1 -Android -SkipCopy
```

**Features**:
- ✅ Automatic prerequisite checking
- ✅ Auto-installs missing Rust targets
- ✅ Builds for all architectures
- ✅ Copies libraries to correct locations
- ✅ Clear error messages with solutions
- ✅ Build progress indicators

**Prerequisites**:
- **Android**: Android NDK, cargo-ndk
- **iOS**: macOS (or use GitHub Actions)

---

### `build_all_mobile.ps1` - Quick Build

One-command build for both platforms.

**Usage**:
```powershell
.\scripts\build_all_mobile.ps1
```

Equivalent to: `.\scripts\build_mobile_libs.ps1 -All`

---

### `build_android.ps1` - Legacy Android Script

Original Android-only build script.

**Deprecated**: Use `build_mobile_libs.ps1 -Android` instead.

---

### `generate_bridge.ps1` - FFI Bridge Generator

Regenerates Flutter-Rust bridge code.

**Usage**:
```powershell
.\scripts\generate_bridge.ps1
```

Run after modifying Rust API signatures.

---

### `test_windows.ps1` - Windows Testing

Runs all tests on Windows desktop build.

**Usage**:
```powershell
.\scripts\test_windows.ps1
```

---

## Quick Reference

```powershell
# Build Android on Windows
.\scripts\build_mobile_libs.ps1 -Android

# Regenerate FFI bridge
.\scripts\generate_bridge.ps1

# Run all tests
.\scripts\test_windows.ps1

# Build everything
.\scripts\build_all_mobile.ps1
```

---

## iOS Note

**iOS cannot be built on Windows**. The script will show this message:

```
⚠️ iOS Build Failed (Expected on Windows)

iOS builds require:
  • macOS with Xcode Command Line Tools
  • Apple's clang compiler with iOS SDK
  • xcrun tool (part of Xcode)

✅ Solutions:
  1. Use GitHub Actions (FREE)
  2. Use cloud Mac service
  3. Build on physical Mac
```

Use GitHub Actions (already configured) or see [MOBILE_COMPILATION_SUMMARY.md](../MOBILE_COMPILATION_SUMMARY.md).

---

## Output Locations

After successful build:

```
android/src/main/jniLibs/
├── arm64-v8a/
│   └── libbulletproof.so
├── armeabi-v7a/
│   └── libbulletproof.so
├── x86_64/
│   └── libbulletproof.so
└── x86/
    └── libbulletproof.so

ios/Frameworks/
├── libzetrix_vc_flutter.a            # Device
├── libzetrix_vc_flutter_sim_arm64.a  # Simulator (M1/M2)
└── libzetrix_vc_flutter_sim_x64.a    # Simulator (Intel)
```

---

## Troubleshooting

### "cargo-ndk not found"
```powershell
cargo install cargo-ndk
```

### "ANDROID_NDK_HOME not set"
```powershell
$env:ANDROID_NDK_HOME = "$env:ANDROID_HOME\ndk\27.0.12077973"
```

Or install via Android Studio: Settings → SDK Tools → NDK

### "failed to find tool xcrun" (iOS)
This is expected on Windows. Use GitHub Actions instead.

---

## More Info

- Full guide: [MOBILE_BUILD_GUIDE.md](../MOBILE_BUILD_GUIDE.md)
- iOS/Android summary: [MOBILE_COMPILATION_SUMMARY.md](../MOBILE_COMPILATION_SUMMARY.md)
- GitHub Actions: [.github/workflows/README.md](../.github/workflows/README.md)
