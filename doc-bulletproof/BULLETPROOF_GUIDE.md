# 🔐 Bulletproof Range Proofs - Complete Guide

## 📋 Table of Contents
1. [What are Bulletproofs?](#what-are-bulletproofs)
2. [Architecture Overview](#architecture-overview)
3. [How It Works](#how-it-works)
4. [How to Use](#how-to-use)
5. [Compilation Guide](#compilation-guide)
6. [Android & iOS Deployment](#android--ios-deployment)
7. [Offline Operation](#offline-operation)
8. [Integration with Zetrix VC](#integration-with-zetrix-vc)

---

## 🎯 What are Bulletproofs?

**Bulletproofs** are zero-knowledge range proofs that allow you to prove a value lies within a range WITHOUT revealing the actual value.

### Real-World Example:
```dart
// Prove: "I am over 18 years old" without revealing your age
// Prove: "My CGPA is between 2.9 and 4.0" without revealing exact CGPA
// Prove: "My salary is above minimum wage" without revealing salary
```

### Key Benefits:
- ✅ **Privacy**: Value remains hidden
- ✅ **Verifiable**: Anyone can verify the proof
- ✅ **Compact**: Small proof size (~1-2KB)
- ✅ **Offline**: Works without network/backend
- ✅ **Aggregatable**: Multiple proofs can be combined

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         BulletproofService (Dart)                     │  │
│  │  - generateSingleMinRangeProof()                      │  │
│  │  - generateMultipleMinMaxRangeProof()                 │  │
│  │  - verifyMultipleRangeProof()                         │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│                       ▼                                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │    FFI Bridge (flutter_rust_bridge v2)               │  │
│  │  - frb_generated.dart                                 │  │
│  │  - Automatic memory management                        │  │
│  │  - Type conversion (Dart ↔ Rust)                      │  │
│  └────────────────────┬─────────────────────────────────┘  │
└────────────────────────┼─────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│           Rust Native Library (.so / .dylib / .dll)         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Bulletproof Core (rust/src/bulletproof/mod.rs)      │  │
│  │  - prover.rs: Generate proofs                         │  │
│  │  - verifier.rs: Verify proofs                         │  │
│  │  - Uses bulletproofs crate 4.0                        │  │
│  │  - Curve25519-dalek-ng (elliptic curve crypto)       │  │
│  │  - Merlin transcript (Fiat-Shamir)                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities:

1. **Dart Service Layer** (`BulletproofService`)
   - High-level API for Flutter apps
   - Input validation
   - Base64URL encoding/decoding
   - Error handling

2. **FFI Bridge** (`flutter_rust_bridge`)
   - Automatic code generation
   - Type marshalling
   - Memory safety
   - Cross-platform compatibility

3. **Rust Core** (`bulletproof/mod.rs`)
   - Cryptographic operations
   - Proof generation/verification
   - Power-of-2 padding handling
   - Pedersen commitments

---

## ⚙️ How It Works

### 1. Proof Generation Flow

```rust
// Step 1: Prepare values
values = [25, 12121]  // Your secret values
mins   = [18, 10000]  // Minimum bounds
maxs   = [100, 50000] // Maximum bounds

// Step 2: Transform to range proofs
// For min-max, we prove:
//   - (value - min) ≥ 0    (lower bound)
//   - (max - value) ≥ 0    (upper bound)

proof_values = []
for each value, min, max:
    if min > 0:
        proof_values.push(value - min)  // Lower bound
    if max > 0:
        proof_values.push(max - value)  // Upper bound

// Result: [25-18, 100-25, 12121-10000, 50000-12121]
//       = [7, 75, 2121, 37879]

// Step 3: Power-of-2 padding
// Bulletproofs requires party_capacity to be power of 2
original_length = 4  // Already power of 2, no padding needed
party_capacity = 4

// If it was 3 values:
// original_length = 3
// party_capacity = 4  // Next power of 2
// padded_values = [v1, v2, v3, 0]  // Pad with zero

// Step 4: Generate Pedersen commitments
// For each value v:
//   commitment = v*G + blinding*H
//   where G, H are generators on Ristretto curve

// Step 5: Create bulletproof
// Uses Fiat-Shamir transform with Merlin transcript
// Transcript label: "zetrix-bulletproof"
// Domain appended as message for context binding

// Step 6: Serialize to Base64URL with 'u' prefix
proof = "uABCD1234..." // Base64URL encoded
commitments = ["uXYZ...", "uABC...", ...]
```

### 2. Proof Verification Flow

```rust
// Step 1: Decode proof and commitments from Base64URL
proof_bytes = decode_base64url(proof)
commitment_points = []
for each commitment:
    point = decode_base64url(commitment)
    commitment_points.push(point)

// Step 2: Initialize verifier
party_capacity = commitment_points.length  // Must match prover
bulletproof_gens = BulletproofGens::new(bitsize, party_capacity)
pedersen_gens = PedersenGens::default()

// Step 3: Recreate transcript with same label + domain
transcript = Transcript::new("zetrix-bulletproof")
transcript.append_message("dom", domain)

// Step 4: Verify proof
result = RangeProof::verify_multiple(
    proof,
    bulletproof_gens,
    pedersen_gens,
    transcript,
    commitment_points,
    bitsize
)

// Step 5: For min-max verification, check expected commitment count
expected_commitments = 0
for each min, max:
    if min > 0: expected_commitments++
    if max > 0: expected_commitments++

// Pad to power of 2
padded_expected = next_power_of_two(expected_commitments)

// Must match: commitment_points.length == padded_expected
```

### 3. Power-of-2 Padding Logic

The bulletproofs crate **requires** `party_capacity` to be a power of 2 for aggregation to work:

| Values | Commitments Needed | Party Capacity | Padding |
|--------|-------------------|----------------|---------|
| 1 | 1 | 1 | None ✅ |
| 2 | 2 | 2 | None ✅ |
| 3 | 3 | 4 | +1 zero commitment |
| 4 | 4 | 4 | None ✅ |
| 5 | 5 | 8 | +3 zero commitments |

**Why this matters:**
- Prover MUST pad values to power of 2
- Prover MUST return ALL commitments (including padded)
- Verifier MUST receive ALL commitments
- Verifier MUST use same party_capacity as prover

---

## 📚 How to Use

### Step 1: Initialize Rust Library

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';

void main() async {
  // Initialize Rust bridge (call once at app startup)
  await RustLib.init();
  
  runApp(MyApp());
}
```

### Step 2: Create Service Instance

```dart
class MyProofService {
  final BulletproofService _bulletproofService = BulletproofService();
  
  // Ready to use!
}
```

### Step 3: Generate Proofs

#### Example 1: Age Verification (≥18)

```dart
Future<BulletproofProof> proveAgeOver18(int age) async {
  return await _bulletproofService.generateSingleMinRangeProof(
    value: age,        // Your actual age (e.g., 25)
    min: 18,           // Minimum age required
    bitSize: 32,       // Bit size for range (32 = up to ~4 billion)
    domain: 'age-verification',  // Context identifier
  );
}

// Usage
final proof = await proveAgeOver18(25);
print('Proof: ${proof.proofValue}');  // uABCD1234...
print('Commitments: ${proof.commitments}');  // [uXYZ...]
```

#### Example 2: CGPA Range (2.9 - 4.0)

```dart
Future<BulletproofProof> proveCgpaInRange(double cgpa) async {
  // Scale decimal to integer (3.45 → 345)
  int scaledCgpa = BulletproofUtil.scaleDecimal(cgpa, 2);
  int scaledMin = BulletproofUtil.scaleDecimal(2.9, 2);   // 290
  int scaledMax = BulletproofUtil.scaleDecimal(4.0, 2);   // 400
  
  return await _bulletproofService.generateSingleMinMaxRangeProof(
    value: scaledCgpa,
    min: scaledMin,
    max: scaledMax,
    bitSize: 32,
    domain: 'cgpa-verification',
  );
}

// Usage
final proof = await proveCgpaInRange(3.45);
print('Commitments: ${proof.commitments.length}');  // 2 (lower + upper)
```

#### Example 3: Multiple Attributes (Age + CGPA)

```dart
Future<BulletproofProof> proveAgeAndCgpa({
  required int age,
  required double cgpa,
}) async {
  int scaledCgpa = BulletproofUtil.scaleDecimal(cgpa, 2);
  
  return await _bulletproofService.generateMultipleMinMaxRangeProof(
    values: [age, scaledCgpa],
    mins: [18, 290],      // Age ≥18, CGPA ≥2.9
    maxs: [0, 400],       // No max for age, CGPA ≤4.0
    bitSize: 32,
    domain: 'combined-verification',
  );
}

// Usage
final proof = await proveAgeAndCgpa(age: 22, cgpa: 3.45);
// Proof contains:
// - 1 commitment for age (only lower bound, max=0)
// - 2 commitments for CGPA (lower + upper bound)
// - 1 padding commitment (3 → 4 for power of 2)
// Total: 4 commitments
```

### Step 4: Verify Proofs

#### Verify Simple Range Proof

```dart
Future<bool> verifyAgeProof(BulletproofProof proof) async {
  return await _bulletproofService.verifyMultipleRangeProof(
    proof: proof,
  );
  // Returns true if valid, false otherwise
}
```

#### Verify Min-Max Proof

```dart
Future<bool> verifyCgpaProof(BulletproofProof proof) async {
  int scaledMin = BulletproofUtil.scaleDecimal(2.9, 2);
  int scaledMax = BulletproofUtil.scaleDecimal(4.0, 2);
  
  return await _bulletproofService.verifySingleMinMaxRangeProof(
    min: scaledMin,
    max: scaledMax,
    proof: proof,
  );
}
```

#### Verify Multiple Min-Max Proof

```dart
Future<bool> verifyAgeAndCgpaProof(BulletproofProof proof) async {
  return await _bulletproofService.verifyMultipleMinMaxRangeProof(
    mins: [18, 290],
    maxs: [0, 400],
    proof: proof,
  );
}
```

### Step 5: Serialize/Deserialize Proofs

```dart
// Convert to JSON (for storage/transmission)
Map<String, dynamic> proofJson = proof.toJson();
String jsonString = jsonEncode(proofJson);

// Send over network, save to database, etc.

// Restore from JSON
Map<String, dynamic> decoded = jsonDecode(jsonString);
BulletproofProof restoredProof = BulletproofProof.fromJson(decoded);

// Verify restored proof
bool isValid = await _bulletproofService.verifyMultipleRangeProof(
  proof: restoredProof,
);
```

---

## 🔨 Compilation Guide

### Prerequisites

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Flutter Rust Bridge CodeGen
cargo install flutter_rust_bridge_codegen

# Install cargo-ndk (for Android)
cargo install cargo-ndk

# Install Android NDK (via Android Studio SDK Manager)
# Install Xcode (for iOS, macOS only)
```

### Windows Development Build

```powershell
# Build Rust library for Windows
cd rust
cargo build --release

# Output: rust/target/release/zetrix_vc_flutter.dll
```

### Generate FFI Bridge (After Rust Changes)

```bash
# Run bridge generator
flutter_rust_bridge_codegen generate

# This creates:
# - lib/frb_generated.dart
# - lib/frb_generated.io.dart
# - lib/frb_generated.web.dart
# - rust/src/frb_generated.rs
```

---

## 📱 Android & iOS Deployment

### Android Compilation

#### Step 1: Add Rust Targets

```bash
rustup target add aarch64-linux-android    # ARM64 (most phones)
rustup target add armv7-linux-androideabi  # ARM32 (older devices)
rustup target add x86_64-linux-android     # x86_64 emulators
rustup target add i686-linux-android       # x86 emulators
```

#### Step 2: Configure NDK Path

```bash
# Set NDK path (adjust version as needed)
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.1.10909125

# Or add to ~/.bashrc / ~/.zshrc
```

#### Step 3: Build for Android

```bash
cd rust

# Build for all Android architectures
cargo ndk \
  --target aarch64-linux-android \
  --target armv7-linux-androideabi \
  --target x86_64-linux-android \
  --target i686-linux-android \
  build --release

# Outputs:
# target/aarch64-linux-android/release/libbulletproof.so
# target/armv7-linux-androideabi/release/libbulletproof.so
# target/x86_64-linux-android/release/libbulletproof.so
# target/i686-linux-android/release/libbulletproof.so
```

#### Step 4: Copy to Android JNI Folder

```bash
# Create jniLibs directories
mkdir -p ../android/src/main/jniLibs/arm64-v8a
mkdir -p ../android/src/main/jniLibs/armeabi-v7a
mkdir -p ../android/src/main/jniLibs/x86_64
mkdir -p ../android/src/main/jniLibs/x86

# Copy libraries
cp target/aarch64-linux-android/release/libbulletproof.so \
   ../android/src/main/jniLibs/arm64-v8a/

cp target/armv7-linux-androideabi/release/libbulletproof.so \
   ../android/src/main/jniLibs/armeabi-v7a/

cp target/x86_64-linux-android/release/libbulletproof.so \
   ../android/src/main/jniLibs/x86_64/

cp target/i686-linux-android/release/libbulletproof.so \
   ../android/src/main/jniLibs/x86/

cd ..
```

#### Step 5: Build Flutter Android App

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Install on device
flutter install
```

### iOS Compilation

#### Step 1: Add iOS Targets

```bash
rustup target add aarch64-apple-ios        # iPhone/iPad
rustup target add x86_64-apple-ios         # Simulator (Intel)
rustup target add aarch64-apple-ios-sim    # Simulator (Apple Silicon)
```

#### Step 2: Install cargo-lipo (for fat binaries)

```bash
cargo install cargo-lipo
```

#### Step 3: Build for iOS

```bash
cd rust

# Build for iPhone/iPad (ARM64)
cargo build --release --target aarch64-apple-ios

# Build for simulator
cargo build --release --target aarch64-apple-ios-sim   # M1/M2 Mac
cargo build --release --target x86_64-apple-ios        # Intel Mac

# Create universal library (optional)
cargo lipo --release

# Outputs:
# target/aarch64-apple-ios/release/libzetrix_vc_flutter.a
# target/universal/release/libzetrix_vc_flutter.a
```

#### Step 4: Update Podspec (if needed)

Edit `ios/zetrix_vc_flutter.podspec`:

```ruby
Pod::Spec.new do |s|
  s.name             = 'zetrix_vc_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Zetrix VC Flutter Plugin'
  s.homepage         = 'https://github.com/yourorg/zetrix_vc_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Team' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  
  # Link to Rust library
  s.vendored_libraries = 'Frameworks/libzetrix_vc_flutter.a'
  
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
```

#### Step 5: Copy Library to iOS Frameworks

```bash
cp target/aarch64-apple-ios/release/libzetrix_vc_flutter.a \
   ../ios/Frameworks/

cd ..
```

#### Step 6: Build Flutter iOS App

```bash
# Build iOS app
flutter build ios --release

# Or open in Xcode
open ios/Runner.xcworkspace
```

---

## 🌐 Offline Operation

### Why It Works Offline

1. **No Network Calls**: All cryptographic operations run locally
2. **Native Libraries**: Compiled into app binary (.so/.dylib/.dll)
3. **No Backend Required**: No API calls, no servers
4. **Pure Mathematics**: Only uses elliptic curve cryptography

### Offline Architecture

```
┌─────────────────────────────────────┐
│     Mobile Device (Offline)         │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Flutter App                 │  │
│  │   - UI Layer                  │  │
│  │   - BulletproofService        │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│             ▼                       │
│  ┌──────────────────────────────┐  │
│  │   Native Library              │  │
│  │   (.so / .dylib / .dll)       │  │
│  │                               │  │
│  │   - Bulletproofs crate        │  │
│  │   - Curve25519-dalek          │  │
│  │   - Pure Rust crypto          │  │
│  └───────────────────────────────┘  │
│                                     │
│  ✅ All operations in-memory       │
│  ✅ No network required             │
│  ✅ Instant proof generation        │
└─────────────────────────────────────┘
```

### What You CAN Do Offline

✅ Generate range proofs  
✅ Verify range proofs  
✅ Serialize proofs to JSON  
✅ Deserialize proofs from JSON  
✅ Calculate proof parameters  
✅ Encode/decode Base64URL  

### What You CANNOT Do (Doesn't Apply)

❌ Query blockchain (not needed for bulletproofs)  
❌ Call REST APIs (not part of bulletproofs)  
❌ Download verification keys (locally compiled)  

### Performance (Approximate)

| Operation | Time | Notes |
|-----------|------|-------|
| Single proof generation | 5-20ms | Depends on bitsize |
| Multi proof (2 values) | 10-30ms | Power-of-2 padding |
| Multi proof (4 values) | 15-40ms | Already power-of-2 |
| Verification | 5-15ms | Faster than generation |
| Serialization | <1ms | Just Base64 encoding |

---

## 🔗 Integration with Zetrix VC

### Complete Service Stack

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

// Available services:
- BulletproofService()           // Range proofs (NEW)
- ZetrixVcService()              // Verifiable Credentials
- ZetrixVpService()              // Verifiable Presentations
- ZetrixVcEncryptedService()     // Encrypted VCs
- ZetrixVpEncryptedService()     // Encrypted VPs
- ZetrixAccountService()         // Account management
- Bbs()                          // BBS+ signatures
- TokenService()                 // JWT tokens
- PackMessageService()           // DIDComm packing
- UnpackMessageService()         // DIDComm unpacking
```

### Use Case: Selective Disclosure with Range Proofs

```dart
class CredentialService {
  final ZetrixVcService _vcService = ZetrixVcService();
  final BulletproofService _bpService = BulletproofService();
  
  /// Create VC with embedded range proof
  Future<Map<String, dynamic>> createVcWithRangeProof({
    required Map<String, dynamic> credentialSubject,
    required int age,
    required double cgpa,
  }) async {
    // Generate range proofs
    final ageProof = await _bpService.generateSingleMinRangeProof(
      value: age,
      min: 18,
      domain: 'age-verification',
    );
    
    final cgpaProof = await _bpService.generateSingleMinMaxRangeProof(
      value: BulletproofUtil.scaleDecimal(cgpa, 2),
      min: BulletproofUtil.scaleDecimal(2.9, 2),
      max: BulletproofUtil.scaleDecimal(4.0, 2),
      domain: 'cgpa-verification',
    );
    
    // Embed proofs in credential
    credentialSubject['ageProof'] = ageProof.toJson();
    credentialSubject['cgpaProof'] = cgpaProof.toJson();
    
    // Create VC (existing functionality)
    return await _vcService.createCredential(
      credentialSubject: credentialSubject,
      issuer: 'did:zetrix:issuer123',
      // ... other VC parameters
    );
  }
  
  /// Verify VC with range proofs
  Future<bool> verifyVcWithRangeProofs(Map<String, dynamic> vc) async {
    final subject = vc['credentialSubject'];
    
    // Verify VC signature (existing functionality)
    bool vcValid = await _vcService.verifyCredential(vc);
    if (!vcValid) return false;
    
    // Verify age proof
    final ageProofJson = subject['ageProof'];
    final ageProof = BulletproofProof.fromJson(ageProofJson);
    bool ageValid = await _bpService.verifyMultipleRangeProof(
      proof: ageProof,
    );
    
    // Verify CGPA proof
    final cgpaProofJson = subject['cgpaProof'];
    final cgpaProof = BulletproofProof.fromJson(cgpaProofJson);
    bool cgpaValid = await _bpService.verifySingleMinMaxRangeProof(
      min: BulletproofUtil.scaleDecimal(2.9, 2),
      max: BulletproofUtil.scaleDecimal(4.0, 2),
      proof: cgpaProof,
    );
    
    return ageValid && cgpaValid;
  }
}
```

### Use Case: Zero-Knowledge Verifiable Presentation

```dart
class PresentationService {
  final ZetrixVpService _vpService = ZetrixVpService();
  final BulletproofService _bpService = BulletproofService();
  
  /// Create VP with range proofs (selective disclosure)
  Future<Map<String, dynamic>> createZkPresentation({
    required String holderDid,
    required int actualAge,
    required double actualCgpa,
  }) async {
    // Generate proofs WITHOUT revealing actual values
    final combinedProof = await _bpService.generateMultipleMinMaxRangeProof(
      values: [actualAge, BulletproofUtil.scaleDecimal(actualCgpa, 2)],
      mins: [18, 290],
      maxs: [0, 400],  // 0 = no max for age
      domain: 'zk-presentation',
    );
    
    // Create VP with proofs only (no actual values)
    return await _vpService.createPresentation(
      holder: holderDid,
      verifiableCredential: [],
      proof: {
        'type': 'BulletproofRangeProof',
        'rangeProof': combinedProof.toJson(),
        'disclosedAttributes': {
          // Only disclose that requirements are met
          'ageOver18': true,
          'cgpaInRange': true,
        },
        // Actual values NOT disclosed!
      },
    );
  }
}
```

---

## 🧪 Testing

### Run All Bulletproof Tests

```bash
# Original test suite (18 tests)
flutter test test/bulletproof_test.dart

# Java compatibility tests (6 tests)
flutter test test/bulletproof_java_compatibility_test.dart

# All bulletproof tests (24 tests)
flutter test test/bulletproof_test.dart test/bulletproof_java_compatibility_test.dart

# All project tests
flutter test
```

### Test Coverage

- ✅ Utility functions (scaling, bit size calculation)
- ✅ Single range proofs (min, max, min-max)
- ✅ Multiple range proofs (2+ values)
- ✅ Power-of-2 padding scenarios
- ✅ Serialization (JSON round-trip)
- ✅ Edge cases (exact bounds, zero values)
- ✅ Java API compatibility

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "Library not loaded" Error

**Problem**: Native library not found at runtime

**Solution**:
```bash
# Rebuild Rust library
cd rust && cargo build --release && cd ..

# For Android, ensure JNI libs are copied
# For iOS, ensure Frameworks folder has .a file
```

#### 2. "InvalidAggregation" Error

**Problem**: Power-of-2 requirement violated

**Solution**: This should be handled automatically by the prover. If you see this, ensure:
```rust
// In prover.rs
let party_capacity = original_len.next_power_of_two();
// Pad values to party_capacity
```

#### 3. Verification Fails

**Problem**: Proof verification returns false

**Check**:
- Domain matches between generation and verification
- Bitsize matches
- Min/max values match (for min-max verification)
- All commitments are present (including padded)

#### 4. Build Errors on Android

**Problem**: NDK not found or wrong version

**Solution**:
```bash
# Check NDK installation
ls $ANDROID_HOME/ndk/

# Set correct version
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.1.10909125
```

---

## 📖 API Reference

### BulletproofService

#### Generation Methods

```dart
// Single value - minimum only
Future<BulletproofProof> generateSingleMinRangeProof({
  required int value,
  required int min,
  int bitSize = 64,
  String domain = 'default',
})

// Single value - maximum only
Future<BulletproofProof> generateSingleMaxRangeProof({
  required int value,
  required int max,
  int bitSize = 64,
  String domain = 'default',
})

// Single value - min and max
Future<BulletproofProof> generateSingleMinMaxRangeProof({
  required int value,
  required int min,
  required int max,
  int bitSize = 64,
  String domain = 'default',
})

// Multiple values - minimum only
Future<BulletproofProof> generateMultipleMinRangeProof({
  required List<int> values,
  required List<int> mins,
  int bitSize = 64,
  String domain = 'default',
})

// Multiple values - maximum only
Future<BulletproofProof> generateMultipleMaxRangeProof({
  required List<int> values,
  required List<int> maxs,
  int bitSize = 64,
  String domain = 'default',
})

// Multiple values - min and max
Future<BulletproofProof> generateMultipleMinMaxRangeProof({
  required List<int> values,
  required List<int> mins,
  required List<int> maxs,
  int bitSize = 64,
  String domain = 'default',
})
```

#### Verification Methods

```dart
// Verify simple range proof
Future<bool> verifyMultipleRangeProof({
  required BulletproofProof proof,
})

// Verify single min-max proof
Future<bool> verifySingleMinMaxRangeProof({
  required int min,
  required int max,
  required BulletproofProof proof,
})

// Verify multiple min-max proof
Future<bool> verifyMultipleMinMaxRangeProof({
  required List<int> mins,
  required List<int> maxs,
  required BulletproofProof proof,
})
```

### BulletproofUtil

```dart
// Scale decimal to integer (3.45, 2) → 345
static int scaleDecimal(double value, int decimalPlaces)

// Unscale integer to decimal (345, 2) → 3.45
static double unscaleDecimal(int value, int decimalPlaces)

// Calculate exact bit size (255) → 8
static int calculateBitSize(int maxValue)

// Recommend standard bit size (256) → 16
static int recommendBitSize(int maxValue)

// Calculate expected commitment count
static int calculateExpectedCommitments(List<int> maxs)
```

### BulletproofProof

```dart
class BulletproofProof {
  final String proofValue;         // Base64URL with 'u' prefix
  final List<String> commitments;  // List of Base64URL commitments
  final int bitSize;               // Bit size used
  final String domain;             // Domain context
  
  // Serialization
  Map<String, dynamic> toJson()
  factory BulletproofProof.fromJson(Map<String, dynamic> json)
}
```

---

## 🎓 Advanced Topics

### Custom Bit Sizes

```dart
// For small values (0-255): use 8 bits
final proof8 = await service.generateSingleMinRangeProof(
  value: 100,
  min: 18,
  bitSize: 8,  // Smaller proof size
);

// For large values: use 64 bits
final proof64 = await service.generateSingleMinRangeProof(
  value: 1000000,
  min: 100000,
  bitSize: 64,  // Support up to 2^64
);
```

### Domain Separation

Use different domains for different contexts:

```dart
// Age verification for voting
final votingProof = await service.generateSingleMinRangeProof(
  value: age,
  min: 18,
  domain: 'voting-eligibility',
);

// Age verification for driving
final drivingProof = await service.generateSingleMinRangeProof(
  value: age,
  min: 16,
  domain: 'driving-license',
);

// Proofs are bound to their domain!
```

### Batch Verification (Future Enhancement)

Currently, each proof must be verified individually. Future versions may support:

```dart
// Not yet implemented
List<bool> results = await service.verifyBatch([proof1, proof2, proof3]);
```

---

## 📝 Summary

✅ **Works Offline**: All crypto operations run locally  
✅ **Cross-Platform**: Compiles for Android, iOS, Windows, macOS, Linux  
✅ **Java Compatible**: Matches Weavechain Java implementation  
✅ **Production Ready**: All 24 tests passing  
✅ **Easy to Use**: Simple Dart API, automatic FFI bridge  
✅ **Type Safe**: Strong typing in Dart and Rust  
✅ **Memory Safe**: Rust's ownership system prevents leaks  
✅ **Fast**: Native performance, <50ms per proof  

**Next Steps:**
1. Build for your target platforms (Android/iOS)
2. Integrate with existing Zetrix VC/VP workflows
3. Test on real devices
4. Deploy to production! 🚀

For questions or issues, check:
- [BULLETPROOF_IMPLEMENTATION.md](BULLETPROOF_IMPLEMENTATION.md) - Technical details
- [test/bulletproof_test.dart](test/bulletproof_test.dart) - Usage examples
- [rust/src/bulletproof/](rust/src/bulletproof/) - Rust implementation
