# Bulletproof Range Proofs Implementation

## Overview

This implementation provides **Bulletproof zero-knowledge range proofs** for Flutter, matching the Java `com.weavechain.bulletproofs` library API. It works offline on both **Android and iOS** using Rust cryptography via Flutter Rust Bridge.

## What are Bulletproofs?

Bulletproofs are **short, non-interactive zero-knowledge proofs** that allow you to prove a value is within a certain range **without revealing the actual value**. They're perfect for privacy-preserving credentials.

### Use Cases

- **Age Verification**: Prove `age >= 18` without revealing exact age
- **Income Range**: Prove `income >= $50,000` without revealing exact salary  
- **GPA Range**: Prove `2.9 <= GPA <= 4.0` without revealing exact GPA
- **Credit Score**: Prove `score >= 700` without revealing exact score

## Architecture

```
┌─────────────────┐
│  Flutter/Dart   │  ← BulletproofService, BulletproofUtil
├─────────────────┤
│ Flutter Rust    │  ← FFI Bridge (auto-generated)
│     Bridge      │
├─────────────────┤
│   Rust Core     │  ← bulletproofs crate (Curve25519)
│  (Native Code)  │     merlin transcripts, Pedersen commitments
└─────────────────┘
```

## Setup Instructions

### Prerequisites

1. **Rust Toolchain** (1.70+)
   ```powershell
   # Install Rust
   winget install Rustlang.Rustup
   
   # Add targets for mobile
   rustup target add aarch64-linux-android
   rustup target add armv7-linux-androideabi
   rustup target add x86_64-linux-android
   rustup target add i686-linux-android
   rustup target add aarch64-apple-ios
   rustup target add x86_64-apple-ios
   ```

2. **Flutter Rust Bridge CLI**
   ```powershell
   cargo install flutter_rust_bridge_codegen
   ```

3. **LLVM** (for code generation)
   ```powershell
   winget install LLVM.LLVM
   ```

### Generate FFI Bridge

Run the bridge generator script:

```powershell
# Windows PowerShell
.\scripts\generate_bridge.ps1

# Or manually
flutter_rust_bridge_codegen `
  --rust-input rust\src\api.rs `
  --dart-output lib\src\bridge_generated.dart
```

This generates:
- `lib/src/bridge_generated.dart` - Dart FFI bindings
- `rust/src/bridge_generated.rs` - Rust FFI glue code

### Build Native Libraries

**Android:**
```bash
cd rust
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
```

**iOS:**
```bash
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios
```

## API Reference (Matching Java)

### BulletproofService

Main service class for generating and verifying proofs.

#### Generation Methods

```dart
// 1. Single minimum range proof: value >= min
Future<BulletproofProof> generateSingleMinRangeProof({
  required int value,
  required int min,
  int bitSize = 32,
  String domain = 'zetrix-vc',
})

// 2. Single maximum range proof: value <= max
Future<BulletproofProof> generateSingleMaxRangeProof({
  required int value,
  required int max,
  int bitSize = 32,
  String domain = 'zetrix-vc',
})

// 3. Single min-max range proof: min <= value <= max
Future<BulletproofProof> generateSingleMinMaxRangeProof({
  required int value,
  required int min,
  required int max,
  int bitSize = 32,
  String domain = 'zetrix-vc',
})

// 4. Multiple minimum range proofs: values[i] >= mins[i]
Future<BulletproofProof> generateMultipleMinRangeProof({
  required List<int> values,
  required List<int> mins,
  int bitSize = 32,
  String domain = 'zetrix-vc',
})

// 5. Multiple maximum range proofs: values[i] <= maxs[i]
Future<BulletproofProof> generateMultipleMaxRangeProof({
  required List<int> values,
  required List<int> maxs,
  int bitSize = 32,
  String domain = 'zetrix-vc',
})

// 6. Multiple min-max range proofs: mins[i] <= values[i] <= maxs[i]
//    Use max=0 to indicate no maximum constraint
Future<BulletproofProof> generateMultipleMinMaxRangeProof({
  required List<int> values,
  required List<int> mins,
  required List<int> maxs,  // 0 = no max
  int bitSize = 32,
  String domain = 'zetrix-vc',
})
```

#### Verification Methods

```dart
// Verify any range proof
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

Helper utilities for working with proofs.

```dart
// Scale decimal to integer (for decimal values like GPA)
static int scaleDecimal(double value, int decimalPlaces)

// Unscale integer back to decimal
static double unscaleDecimal(int value, int decimalPlaces)

// Scale multiple decimals
static List<int> scaleDecimals(List<double> values, int decimalPlaces)

// Calculate appropriate bit size for a value
static int calculateBitSize(int value)

// Recommend standard bit size (8, 16, 32, or 64)
static int recommendBitSize(int maxValue)

// Validate value is in range
static bool isInRange(int value, int min, int max)

// Calculate expected commitment count
static int calculateExpectedCommitments(List<int> maxs)
```

## Usage Examples

### Example 1: Age Verification (Matching Java)

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() async {
  final service = BulletproofService(ZetrixVcFlutter());

  // Prove age >= 18
  final proof = await service.generateSingleMinRangeProof(
    value: 22,
    min: 18,
    bitSize: 32,
    domain: 'age-verification',
  );

  print('Proof: ${proof.proofValue}');
  print('Commitments: ${proof.commitments}');

  // Verify
  final isValid = await service.verifyMultipleRangeProof(proof: proof);
  print('Valid: $isValid');
}
```

### Example 2: Combined Age + GPA (Matching Java Example)

```dart
void main() async {
  final service = BulletproofService(ZetrixVcFlutter());

  // Scale decimal GPA to integer
  int decimalPlaces = 2;
  int cgpa = BulletproofUtil.scaleDecimal(3.45, decimalPlaces);      // 345
  int maxCgpa = BulletproofUtil.scaleDecimal(4.0, decimalPlaces);    // 400
  int minCgpa = BulletproofUtil.scaleDecimal(2.9, decimalPlaces);    // 290

  // Two values: age and CGPA
  List<int> values = [22, cgpa];        // Age, CGPA (scaled)
  List<int> mins = [18, minCgpa];       // Minimums
  List<int> maxs = [0, maxCgpa];        // 0 = no max for age

  // Generate combined proof
  final combinedProof = await service.generateMultipleMinMaxRangeProof(
    values: values,
    mins: mins,
    maxs: maxs,
    bitSize: 32,
    domain: 'combined-range-proof',
  );

  print('Proof (Base64url with Prefix): ${combinedProof.proofValue}');
  
  for (int i = 0; i < combinedProof.commitments.length; i++) {
    print('Commitment[$i]: ${combinedProof.commitments[i]}');
  }

  // Verify
  final isValid = await service.verifyMultipleMinMaxRangeProof(
    mins: mins,
    maxs: maxs,
    proof: combinedProof,
  );
  
  print(isValid 
    ? 'Combined Proof Verification Succeeded!' 
    : 'Combined Proof Verification Failed!');
}
```

### Example 3: Using in Verifiable Presentation

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

Future<VP> createVPWithRangeProof() async {
  final service = BulletproofService(ZetrixVcFlutter());
  
  // Your VP setup...
  final vp = VP(/* ... */);

  // Add range proof for age >= 18
  int age = 25; // Actual age (kept private)
  
  final proof = await service.generateSingleMinRangeProof(
    value: age,
    min: 18,
    bitSize: 32,
    domain: 'zetrix-vc-age',
  );

  // Create RangeProof object and attach to VP
  final rangeProof = RangeProof()
    ..type = ProofTypeEnum.bulletproof.value
    ..proofValue = proof.proofValue
    ..commitments = proof.commitments
    ..bits = proof.bitSize
    ..domain = proof.domain
    ..range = [
      RangeConstraint(attribute: 'age', min: 18, max: null),
    ];

  vp.rangeProof = rangeProof;

  return vp;
}

Future<bool> verifyVPRangeProof(VP vp) async {
  final service = BulletproofService(ZetrixVcFlutter());
  
  if (vp.rangeProof?.type != ProofTypeEnum.bulletproof.value) {
    return false;
  }

  final rangeProof = vp.rangeProof!;
  
  // Extract mins and maxs from range constraints
  final mins = rangeProof.range!.map((r) => r.min ?? 0).toList();
  final maxs = rangeProof.range!.map((r) => r.max ?? 0).toList();

  final proof = BulletproofProof(
    proofValue: rangeProof.proofValue!,
    commitments: rangeProof.commitments!,
    bitSize: rangeProof.bits!,
    domain: rangeProof.domain!,
  );

  return await service.verifyMultipleMinMaxRangeProof(
    mins: mins,
    maxs: maxs,
    proof: proof,
  );
}
```

## Proof Format

### Base64URL Encoding (Matching Java)

All proofs and commitments use **Base64URL encoding with 'u' prefix**:

```
u<base64url_data>
```

Example:
```
uMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC...
```

The 'u' prefix distinguishes Base64URL from standard Base64.

### Commitment Count

For `generateMultipleMinMaxRangeProof`:
- Each value gets **1 commitment** for lower bound (value - min)
- If `max != 0`, adds **1 commitment** for upper bound (max - value)

Examples:
- `values: [22], mins: [18], maxs: [0]` → **1 commitment** (only min)
- `values: [22], mins: [18], maxs: [65]` → **2 commitments** (min + max)
- `values: [22, 345], mins: [18, 290], maxs: [0, 400]` → **3 commitments** (1 + 2)

## Data Models

### BulletproofProof

```dart
class BulletproofProof {
  final String proofValue;        // Base64URL with 'u' prefix
  final List<String> commitments; // Base64URL with 'u' prefix
  final int bitSize;              // Typically 32 or 64
  final String domain;            // Domain separator

  Map<String, dynamic> toJson();
  factory BulletproofProof.fromJson(Map<String, dynamic> json);
}
```

### ProofTypeEnum

```dart
enum ProofTypeEnum {
  bulletproof(3, 'BulletproofRangeProof2021'),
  // ...
}
```

## Comparison with Java Implementation

| Feature | Java (Weavechain) | Flutter (This) | Compatible? |
|---------|-------------------|----------------|-------------|
| **Curve** | Configurable EC | Curve25519 (Ristretto) | ⚠️ Different curves |
| **Transcript** | Custom | Merlin | ⚠️ Different implementations |
| **API** | BulletProofUtil methods | BulletproofService methods | ✅ Identical API |
| **Encoding** | Base64URL with 'u' | Base64URL with 'u' | ✅ Same |
| **Proof Types** | Min/Max/MinMax | Min/Max/MinMax | ✅ Same |
| **Bit Sizes** | 32/64 | 32/64 | ✅ Same |

### ⚠️ Cross-Platform Compatibility

Proofs generated in **Java cannot be verified in Flutter** (and vice versa) because they use different elliptic curves and transcript implementations. However, both implementations:
- Use the same **mathematical principles** (R1CS bulletproofs)
- Have **identical APIs**
- Produce valid proofs **within their own ecosystem**

For cross-platform verification, both systems would need to use the same curve and transcript format.

## Testing

Run the test suite:

```powershell
flutter test test/bulletproof_test.dart
```

Tests include:
- ✅ Single min/max/min-max range proofs
- ✅ Multiple value proofs
- ✅ Decimal scaling (matching Java)
- ✅ Proof serialization
- ✅ Edge cases (exact bounds, no max, etc.)
- ✅ Error cases (value out of range)

## Performance

Typical performance on modern devices:

| Operation | Time | Platform |
|-----------|------|----------|
| Generate single proof | ~100-200ms | Android/iOS |
| Generate 2-value proof | ~150-300ms | Android/iOS |
| Verify proof | ~50-100ms | Android/iOS |

Proof sizes:
- **Proof**: ~700-1000 bytes
- **Commitment**: 32 bytes each

## Troubleshooting

### Bridge Generation Fails

```
Error: flutter_rust_bridge_codegen not found
```

**Solution**: Install the code generator
```powershell
cargo install flutter_rust_bridge_codegen
```

### Compilation Errors

```
Error: bulletproofs crate not found
```

**Solution**: Update dependencies
```powershell
cd rust
cargo update
cargo build
```

### Runtime Errors

```
StateError: BulletproofService not initialized
```

**Solution**: Bridge not generated. Run `generate_bridge.ps1` first.

## Security Considerations

1. **Cryptographic Security**: Uses Curve25519 (Ristretto), considered secure for 128-bit security level

2. **Randomness**: Uses `OsRng` (OS-provided randomness) for blinding factors

3. **Domain Separation**: Always use unique domain strings to prevent cross-protocol attacks

4. **Bit Size**: Use appropriate bit sizes (32 for most values, 64 for large numbers)

5. **Value Validation**: Always validate inputs before generating proofs

## References

- [Bulletproofs Paper](https://eprint.iacr.org/2017/1066.pdf) - Original research paper
- [Rust bulletproofs crate](https://github.com/dalek-cryptography/bulletproofs) - Implementation used
- [Curve25519-dalek](https://github.com/dalek-cryptography/curve25519-dalek) - Elliptic curve operations
- [Flutter Rust Bridge](https://github.com/fzyzcjy/flutter_rust_bridge) - FFI bridging

## License

Same as main project license.
