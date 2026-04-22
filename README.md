## 📦 `zetrix_vc_flutter` Plugin

A Flutter plugin that enables Verifiable Credential (VC) and Verifiable Presentation (VP) generation using [BBS+ signatures](https://identity.foundation/bbs-signature/), built on top of Zetrix blockchain specifications.

This implementation uses **platform-specific native libraries** (Rust-compiled via JNI/FFI) and exposes functionality to Dart via **MethodChannel**.

---

## ✅ Features

* 🧠 BBS+ key generation (BLS12-381)
* ✍️ BBS+ signature creation
* 🔍 Selective disclosure proofs
* 🔐 **Bulletproof Range Proofs**: Zero-knowledge range proofs (prove value in range without revealing it)
* 🧱 Works across Android and iOS (iOS soon)
* 📦 Built as a Flutter plugin (no manual linking for consumers)

---

## 🧭 DCQL Presentation (Wallet Flow)

This plugin includes helpers to produce Verifiable Presentations (VPs)
in response to a DCQL (Digital Credentials Query Language) presentation
request. Key points:

- **Create VP from DCQL**: call `ZetrixVpService().createVPFromDCQL(...)` (or
  use your existing `zetrixVpService` instance) with the presentation request
  JSON (`GET /v1/presentation/{id}`), the holder's Verifiable Credential (VC)
  JSON, and the wallet key material.
- **Presentation submission body**: the returned object serializes to the
  verifier's expected JSON with keys such as `vp_token`, `presentation_id`,
  `presentation_submission`, `ed25519_public_key`, and `bbs_public_key`.
- **Constraints vs filter**: the request may use `constraints` (preferred)
  or the legacy `filter` key; both are supported. Range proofs are requested
  by `minimum`/`maximum` in the constraint and produce BulletProofs; other
  constraints (e.g. `const`, `enum`, `pattern`) are handled via BBS+
  selective disclosure.
- **Path flexibility**: presentation requests may use flat paths like
  `["credentialSubject","nationality"]`. The service attempts an exact
  match and falls back to a deep-search for the requested final field within
  `credentialSubject` (e.g. `credentialSubject.identityCardMalaysia.nationality`).
- **Note on issuer signatures**: the derived BBS+ proof is created from the
  original VC's flattened message list. If you change the VC structure you
  may need the issuer to re-issue the VC for verifier signature checks to
  succeed; the library will still locate nested fields when possible.


---

## 🧹 Project Structure

```
zetrix_vc_flutter/
├── android/
│   ├── src/main/java/.../MethodChannelHandler.java
│   ├── src/main/jniLibs/arm64-v8a/libbbs.so
│   └── ...
├── ios/
│   └── (pending FFI integration)
├── lib/
│   ├── bbs_bindings.dart
│   ├── bbs.dart
│   └── zetrix_vc_flutter.dart
├── example/
└── pubspec.yaml
```

---

## 🔧 How We Integrated Using MethodChannel

### ✅ Step-by-step:

#### 1. **Expose Native Methods via Java (Android)**

We created a wrapper class in `android/src/main/java/.../BbsMethodHandler.java` that maps Dart calls to native Rust bindings via JNI.

Example:

```java
methodChannel.setMethodCallHandler((call, result) -> {
    switch (call.method) {
        case "createBbsProof":
            // call Rust JNI wrapper
            byte[] proof = Bbs.createProof(...);
            result.success(proof);
            break;
        default:
            result.notImplemented();
    }
});
```

#### 2. **Implement Dart `MethodChannel`**

In `bbs.dart`, we use Flutter's `MethodChannel` to call native methods:

```dart
const _channel = MethodChannel('zetrix_vc');

Future<Uint8List> createBbsProof(Map<String, dynamic> args) async {
  final result = await _channel.invokeMethod<Uint8List>('createBbsProof', args);
  return result!;
}
```

#### 3. **Link Native `.so` Library Automatically**

We placed `libbbs.so` in `android/src/main/jniLibs/` so it is automatically bundled into the APK:

```bash
android/
└── src/main/jniLibs/
    └── arm64-v8a/
        └── libbbs.so
```

No manual linking needed from consumers.

#### 4. **Generate and Use JNI Headers**

To link Java and Rust, we generated `bbs_signatures_Bbs.h` using `javac -h`. This header defines all native functions that the Rust/C side must implement.

```bash
javac -h . Bbs.java
```

---

## 🔐 Why MethodChannel?

We chose **MethodChannel over Dart FFI** for Android because:

* JNI is well-documented and stable for native Rust ↔ Java bindings.
* Flutter Android's MethodChannel provides simple serialization and error propagation.
* No need to handle cross-platform memory management at Dart-level.
* Works well with `.so` libraries generated from Rust (`cargo-ndk`, `jni` crate).

---

## 🚀 Usage in Flutter

### BBS+ Signatures

```dart
final proof = await createBbsProof({
  "publicKey": [...],
  "signature": [...],
  "nonce": [...],
  "messages": [...],
});
```

### Bulletproof Range Proofs

```dart
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';

// Initialize (once at app startup)
await RustLib.init();

// Create service
final service = BulletproofService();

// Prove age ≥ 18 without revealing actual age
final proof = await service.generateSingleMinRangeProof(
  value: 25,
  min: 18,
  domain: 'age-verification',
);

// Verify proof
bool isValid = await service.verifyMultipleRangeProof(proof: proof);
print('Valid: $isValid');  // true, actual age stays secret!
```

---

## 📋 TODOs

* [ ] iOS native integration (Obj-C/Swift + Rust static lib)
* [ ] Fallback to Dart FFI for cross-platform consistency

---
## 💪 Build Notes

To rebuild the plugin after modifying native libs:

```bash
flutter clean
flutter pub get
flutter build apk
```

If your app uses this plugin as a dependency:

```yaml
dependencies:
  zetrix_vc_flutter: <VERSION>
```

---

## 🙌 Credits

* [MATTR BBS+ Rust crate](https://github.com/mattrglobal/ffi-bbs-signatures)
* [Bulletproofs Rust crate](https://github.com/dalek-cryptography/bulletproofs)
* [Weavechain Bulletproofs](https://github.com/weavechain/bulletproofs) - Java reference implementation
* [Flutter Rust Bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
* [Flutter MethodChannel Docs](https://docs.flutter.dev/platform-integration/platform-channels)
