# 🚀 Bulletproof Quick Start

Quick reference for using Bulletproof range proofs in your Flutter app.

## 📦 Setup (One-Time)

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';

void main() async {
  await RustLib.init();  // Initialize once at startup
  runApp(MyApp());
}
```

## 💡 Common Use Cases

### 1. Prove Age ≥ 18

```dart
final service = BulletproofService();

// Generate proof
final proof = await service.generateSingleMinRangeProof(
  value: 25,    // Your actual age
  min: 18,      // Minimum required
  domain: 'age-check',
);

// Verify proof
bool isValid = await service.verifyMultipleRangeProof(proof: proof);
print('Age ≥ 18: $isValid');  // true, but actual age stays hidden!
```

### 2. Prove Value in Range (Min-Max)

```dart
// CGPA between 2.9 and 4.0
int cgpa = BulletproofUtil.scaleDecimal(3.45, 2);  // 345

final proof = await service.generateSingleMinMaxRangeProof(
  value: cgpa,
  min: 290,   // 2.9 scaled
  max: 400,   // 4.0 scaled
  domain: 'cgpa-check',
);

bool isValid = await service.verifySingleMinMaxRangeProof(
  min: 290,
  max: 400,
  proof: proof,
);
```

### 3. Multiple Attributes (Age + CGPA)

```dart
final proof = await service.generateMultipleMinMaxRangeProof(
  values: [25, 345],        // Age, CGPA
  mins:   [18, 290],        // Minimums
  maxs:   [0, 400],         // 0 = no max for age
  domain: 'combined-check',
);

bool isValid = await service.verifyMultipleMinMaxRangeProof(
  mins: [18, 290],
  maxs: [0, 400],
  proof: proof,
);
```

## 💾 Save & Load Proofs

```dart
// Save to JSON
Map<String, dynamic> json = proof.toJson();
String jsonString = jsonEncode(json);
await File('proof.json').writeAsString(jsonString);

// Load from JSON
String jsonString = await File('proof.json').readAsString();
Map<String, dynamic> json = jsonDecode(jsonString);
BulletproofProof proof = BulletproofProof.fromJson(json);
```

## 🛠️ Utility Functions

```dart
// Convert decimal to integer
int scaled = BulletproofUtil.scaleDecimal(3.45, 2);  // 345

// Convert back
double original = BulletproofUtil.unscaleDecimal(345, 2);  // 3.45

// Calculate ideal bit size
int bits = BulletproofUtil.recommendBitSize(1000);  // 16

// Calculate bit size exactly
int exact = BulletproofUtil.calculateBitSize(255);  // 8
```

## 📱 Build for Production

### Android

```bash
# Install tools
cargo install cargo-ndk
rustup target add aarch64-linux-android armv7-linux-androideabi

# Build
cd rust
cargo ndk --target aarch64-linux-android --target armv7-linux-androideabi build --release

# Copy libraries
cp target/aarch64-linux-android/release/libbulletproof.so \
   ../android/src/main/jniLibs/arm64-v8a/
cp target/armv7-linux-androideabi/release/libbulletproof.so \
   ../android/src/main/jniLibs/armeabi-v7a/

# Build APK
cd ..
flutter build apk --release
```

### iOS

```bash
# Install tools
rustup target add aarch64-apple-ios

# Build
cd rust
cargo build --release --target aarch64-apple-ios

# Copy library
cp target/aarch64-apple-ios/release/libzetrix_vc_flutter.a \
   ../ios/Frameworks/

# Build iOS
cd ..
flutter build ios --release
```

## ✅ Verification

| Method | Use Case |
|--------|----------|
| `verifyMultipleRangeProof()` | Min-only, Max-only, or simple range |
| `verifySingleMinMaxRangeProof()` | Single value with min and max |
| `verifyMultipleMinMaxRangeProof()` | Multiple values with min and max |

## 🎯 Key Points

✅ **Offline**: No network needed  
✅ **Private**: Value stays hidden  
✅ **Fast**: <50ms per proof  
✅ **Compact**: ~1KB proof size  
✅ **Automatic**: Power-of-2 padding handled internally  

## 📚 More Info

- Full guide: [BULLETPROOF_GUIDE.md](BULLETPROOF_GUIDE.md)
- Tests: [test/bulletproof_test.dart](test/bulletproof_test.dart)
- Java compatibility: [test/bulletproof_java_compatibility_test.dart](test/bulletproof_java_compatibility_test.dart)
