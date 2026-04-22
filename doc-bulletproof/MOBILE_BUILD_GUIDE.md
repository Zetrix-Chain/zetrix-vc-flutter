# 📱 Android & iOS Compilation Guide

## Prerequisites Status

### ✅ Already Installed
- Rust with Android targets (aarch64, armv7, x86_64, i686)
- cargo-ndk build tool
- Flutter SDK with Android toolchain

### ❌ Missing (Required for Mobile)
- **Android NDK** - Required for compiling C/Rust code

---

## 🔧 Install Android NDK

### Option 1: Via Android Studio (Recommended)

1. Open **Android Studio**
2. Go to **Settings** → **Languages & Frameworks** → **Android SDK**
3. Click **SDK Tools** tab
4. Check ✓ **NDK (Side by side)**
5. Click **Apply** and wait for installation

### Option 2: Via Command Line (sdkmanager)

```powershell
# Set Android SDK path
$env:ANDROID_HOME = "C:\Users\mhdfahmi.norolazani\AppData\Local\Android\Sdk"

# Install NDK
cd $env:ANDROID_HOME\cmdline-tools\latest\bin
.\sdkmanager.bat "ndk;27.0.12077973"
```

### Option 3: Manual Download

1. Download NDK from: https://developer.android.com/ndk/downloads
2. Extract to: `C:\Users\mhdfahmi.norolazani\AppData\Local\Android\Sdk\ndk\27.0.12077973`

---

## 🚀 Build for Android (After NDK Installation)

### Step 1: Set Environment Variables

```powershell
# Set Android SDK path
$env:ANDROID_HOME = "C:\Users\mhdfahmi.norolazani\AppData\Local\Android\Sdk"

# Set NDK path (adjust version number)
$env:ANDROID_NDK_HOME = "$env:ANDROID_HOME\ndk\27.0.12077973"

# Verify
echo "ANDROID_HOME: $env:ANDROID_HOME"
echo "NDK: $env:ANDROID_NDK_HOME"
```

### Step 2: Build Rust Libraries for Android

```powershell
cd rust

# Build for all Android architectures
cargo ndk `
  --target aarch64-linux-android `
  --target armv7-linux-androideabi `
  --target x86_64-linux-android `
  --target i686-linux-android `
  build --release

cd ..
```

**Build time**: ~5-10 minutes for all architectures

### Step 3: Copy Libraries to Android JNI Folder

```powershell
# Create JNI directories
New-Item -ItemType Directory -Force -Path "android\src\main\jniLibs\arm64-v8a"
New-Item -ItemType Directory -Force -Path "android\src\main\jniLibs\armeabi-v7a"
New-Item -ItemType Directory -Force -Path "android\src\main\jniLibs\x86_64"
New-Item -ItemType Directory -Force -Path "android\src\main\jniLibs\x86"

# Copy libraries
Copy-Item "rust\target\aarch64-linux-android\release\libbulletproof.so" `
  "android\src\main\jniLibs\arm64-v8a\"

Copy-Item "rust\target\armv7-linux-androideabi\release\libbulletproof.so" `
  "android\src\main\jniLibs\armeabi-v7a\"

Copy-Item "rust\target\x86_64-linux-android\release\libbulletproof.so" `
  "android\src\main\jniLibs\x86_64\"

Copy-Item "rust\target\i686-linux-android\release\libbulletproof.so" `
  "android\src\main\jniLibs\x86\"
```

### Step 4: Build Flutter APK

```powershell
# Build APK
flutter build apk --release

# Or build for specific architecture (smaller APK)
flutter build apk --release --target-platform android-arm64

# Output: build\app\outputs\flutter-apk\app-release.apk
```

### Step 5: Test on Android Device/Emulator

```powershell
# List connected devices
flutter devices

# Install on connected device
flutter install

# Or run directly
cd example
flutter run -d <device-id>
```

---

## 🍎 Build for iOS (Requires macOS)

**Note**: iOS builds require a Mac with Xcode. On Windows, you can only prepare the libraries.

### On macOS:

#### Step 1: Add iOS Targets

```bash
rustup target add aarch64-apple-ios        # iPhone/iPad
rustup target add x86_64-apple-ios         # Simulator (Intel Mac)
rustup target add aarch64-apple-ios-sim    # Simulator (Apple Silicon)
```

#### Step 2: Install cargo-lipo

```bash
cargo install cargo-lipo
```

#### Step 3: Build Rust Libraries

```bash
cd rust

# For device
cargo build --release --target aarch64-apple-ios

# For simulator (M1/M2 Mac)
cargo build --release --target aarch64-apple-ios-sim

# For simulator (Intel Mac)
cargo build --release --target x86_64-apple-ios

# Or create universal library
cargo lipo --release
```

#### Step 4: Copy to iOS Frameworks

```bash
cp target/aarch64-apple-ios/release/libzetrix_vc_flutter.a \
   ../ios/Frameworks/
```

#### Step 5: Build Flutter iOS App

```bash
# Build iOS app
flutter build ios --release

# Or open in Xcode
open ios/Runner.xcworkspace
```

---

## 🖥️ Test on Windows Desktop (Works Now!)

You can test the bulletproof functionality on Windows without NDK:

```powershell
# Already built: rust\target\release\zetrix_vc_flutter.dll

# Run example app
cd example
flutter run -d windows

# Or run tests
cd ..
flutter test test/bulletproof_test.dart
flutter test test/bulletproof_java_compatibility_test.dart
```

---

## ✅ Verification Checklist

### Before Building Mobile:
- [ ] **Android NDK** installed and ANDROID_NDK_HOME set
- [ ] Rust Android targets installed (`rustup target list | Select-String android`)
- [ ] cargo-ndk installed (`cargo ndk --version`)
- [ ] **For iOS**: GitHub Actions configured OR access to macOS

### After Building Android:
- [ ] Check libraries exist: `ls android\src\main\jniLibs\arm64-v8a\libbulletproof.so`
- [ ] APK builds without errors: `flutter build apk --release`
- [ ] App installs on device
- [ ] Bulletproof tests pass on device

---

## 🐛 Troubleshooting

### "failed to find tool 'clang.exe'"
**Solution**: Install Android NDK (see above)

### "error occurred in cc-rs"
**Solution**: Ensure ANDROID_NDK_HOME is set correctly

### "Library not found" at runtime
**Solution**: Verify .so files are in correct jniLibs folders

### NDK version mismatch
**Solution**: Use NDK r21 or later (r27 recommended)

---

## 📊 Build Size Reference

| Platform | Library Size | APK Size |
|----------|-------------|----------|
| Android ARM64 | ~8MB | ~12MB |
| Android ARM32 | ~7MB | ~11MB |
| iOS | ~9MB | ~15MB |
| Windows | ~5MB | - |

---

## 🎯 Quick Commands Summary

```powershell
# 1. Install NDK via Android Studio SDK Manager

# 2. Set environment variables
$env:ANDROID_NDK_HOME = "$env:ANDROID_HOME\ndk\27.0.12077973"

# 3. Build libraries
cd rust
cargo ndk --target aarch64-linux-android --target armv7-linux-androideabi build --release

# 4. Copy libraries (automated script below)
cd ..
.\scripts\copy_android_libs.ps1

# 5. Build APK
flutter build apk --release

# 6. Install
flutter install
```

---

## 🔄 Automated Build Script

**The project now includes a comprehensive build script!**

### Build Everything (iOS + Android)
```powershell
.\scripts\build_all_mobile.ps1
```

### Build Specific Platform
```powershell
# Android only
.\scripts\build_mobile_libs.ps1 -Android

# iOS only
.\scripts\build_mobile_libs.ps1 -iOS

# Both platforms (if prerequisites available)
.\scripts\build_mobile_libs.ps1 -All
```

The script will:
- ✅ Check all prerequisites (Rust, NDK, cargo-ndk)
- ✅ Install missing Rust targets automatically
- ✅ Build libraries for all architectures
- ✅ Copy libraries to correct locations
- ✅ Provide clear error messages and next steps

---

## � GitHub Actions Setup (For iOS)

Since iOS can't be built on Windows, use free CI/CD:

### Create `.github/workflows/build-ios.yml`:

```yaml
name: Build iOS Libraries

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  build-ios:
    runs-on: macos-14  # Apple Silicon
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Rust
        run: |
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
          source $HOME/.cargo/env
          rustup target add aarch64-apple-ios aarch64-apple-ios-sim
      
      - name: Build iOS Libraries
        run: |
          cd rust
          cargo build --release --target aarch64-apple-ios
          cargo build --release --target aarch64-apple-ios-sim
      
      - name: Copy to Frameworks
        run: |
          mkdir -p ios/Frameworks
          cp rust/target/aarch64-apple-ios/release/libzetrix_vc_flutter.a ios/Frameworks/
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ios-libraries
          path: ios/Frameworks/*.a
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Build iOS App (No Codesign)
        run: |
          flutter pub get
          cd example
          flutter build ios --release --no-codesign
      
      - name: Upload iOS App
        uses: actions/upload-artifact@v4
        with:
          name: ios-app
          path: example/build/ios/iphoneos/Runner.app
```

### How to Use:

1. **Commit and push** to GitHub
2. **Go to Actions tab** in your GitHub repo
3. **Download artifacts** after build completes
4. **Copy libraries** from artifacts to your local project

---

## 📚 Next Steps

### For Android (Works on Windows):
1. **Install Android NDK** via Android Studio
2. **Run**: `.\scripts\build_mobile_libs.ps1 -Android`
3. **Build APK**: `flutter build apk --release`
4. **Test on device**: `flutter install`

### For iOS (Requires macOS or CI/CD):
1. **Option A**: Setup GitHub Actions (see above)
2. **Option B**: Use cloud Mac service
3. **Option C**: Build on physical Mac

✅ **Bulletproofs** work on both platforms once built!
