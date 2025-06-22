// ignore_for_file: camel_case_types, constant_identifier_names

import 'dart:ffi';
import 'bbs_ffi_types.dart';

/// A class providing FFI bindings for interacting with the native BBS+ cryptographic library.
///
/// The `BbsBindings` class acts as a Dart wrapper around the native BBS+ functions,
/// enabling cryptographic operations like proof creation, public key conversion, and more
/// through Foreign Function Interface (FFI).
///
/// This class initializes and exposes native library functions that are dynamically loaded
/// at runtime from a [DynamicLibrary]. Each native function is represented by a typedef
/// indicating its signature and an associated Dart function for easier use.
class BbsBindings {
  /// The loaded dynamic library containing the native BBS functions.
  final DynamicLibrary _lib;

  /// Initializes a new instance of `BbsBindings` using the provided dynamic library.
  BbsBindings(this._lib);

  /// Generates a BLS G2 keypair.
  ///
  /// This function links to the native `bls_generate_g2_key` function.
  late final BlsGenerateG2Key blsGenerateG2Key = _lib
      .lookup<NativeFunction<BlsGenerateG2KeyNative>>('bls_generate_g2_key')
      .asFunction();

  /// Converts a BLS public key to a BBS+ public key.
  ///
  /// This function links to the native `bls_public_key_to_bbs_key` function.
  late final BlsPublicKeyToBbsKey blsPublicKeyToBbsKey = _lib
      .lookup<NativeFunction<bls_public_key_to_bbs_key_native>>(
          'bls_public_key_to_bbs_key')
      .asFunction();

  /// Initializes the BBS proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_init` function.
  late final BbsCreateProofContextInit bbsCreateProofContextInit = _lib
      .lookup<NativeFunction<bbs_create_proof_context_init_native>>(
          'bbs_create_proof_context_init')
      .asFunction();

  /// Sets the public key for the BBS proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_set_public_key` function.
  late final BbsCreateProofContextSetPublicKey
      bbsCreateProofContextSetPublicKey = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_public_key_native>>(
            'bbs_create_proof_context_set_public_key',
          )
          .asFunction();

  /// Sets the nonce bytes for the BBS proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_set_nonce_bytes` function.
  late final BbsCreateProofContextSetNonceBytes
      bbsCreateProofContextSetNonceBytes = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_nonce_bytes_native>>(
            'bbs_create_proof_context_set_nonce_bytes',
          )
          .asFunction();

  /// Sets the signature for the BBS proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_set_signature` function.
  late final BbsCreateProofContextSetSignature
      bbsCreateProofContextSetSignature = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_signature_native>>(
            'bbs_create_proof_context_set_signature',
          )
          .asFunction();

  /// Adds a proof message to the proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_add_proof_message_bytes` function.
  late final BbsCreateProofContextAddProofMessageBytes
      bbsCreateProofContextAddProofMessageBytes = _lib
          .lookup<
              NativeFunction<
                  bbs_create_proof_context_add_proof_message_bytes_native>>(
            'bbs_create_proof_context_add_proof_message_bytes',
          )
          .asFunction();

  /// Finalizes the BBS proof creation process.
  ///
  /// This function links to the native `bbs_create_proof_context_finish` function.
  late final BbsCreateProofContextFinish bbsCreateProofContextFinish = _lib
      .lookup<NativeFunction<bbs_create_proof_context_finish_native>>(
        'bbs_create_proof_context_finish',
      )
      .asFunction();

  /// Retrieves the size of the BBS proof creation context.
  ///
  /// This function links to the native `bbs_create_proof_context_size` function.
  late final BbsCreateProofContextSize bbsCreateProofContextSize = _lib
      .lookup<NativeFunction<bbs_create_proof_context_size_native>>(
          'bbs_create_proof_context_size')
      .asFunction();
}

//
// Typedefs for FFI binding functions
//

/// Native function signature for `bbs_create_proof_context_size`.
typedef bbs_create_proof_context_size_native = Int32 Function(Uint64 handle);

/// Dart typedef for use with the `bbs_create_proof_context_size` native function.
typedef BbsCreateProofContextSize = int Function(int handle);

/// Native function signature for retrieving the size of a BBS+ proof.
typedef bbs_create_proof_size_native = Int32 Function(Uint64 handle);

/// Dart-friendly typedef for retrieving the size of a BBS+ proof.
typedef BbsCreateProofSize = int Function(int handle);

/// Native function signature for `bbs_create_proof_context_finish`.
typedef bbs_create_proof_context_finish_native = Int32 Function(
  Uint64 handle,
  Pointer<ByteBuffer> proof,
  Pointer<ExternError> err,
);

/// Dart typedef for the `bbs_create_proof_context_finish` function.
typedef BbsCreateProofContextFinish = int Function(
  int handle,
  Pointer<ByteBuffer> proof,
  Pointer<ExternError> err,
);

/// Native function signature for `bbs_create_proof_context_add_proof_message_bytes`.
typedef bbs_create_proof_context_add_proof_message_bytes_native = Int32
    Function(
  Uint64 handle,
  ByteArray message,
  Int32 xtype,
  ByteArray blinding,
  Pointer<ExternError> err,
);

/// Dart typedef for adding proof message bytes to the context.
typedef BbsCreateProofContextAddProofMessageBytes = int Function(
  int handle,
  ByteArray message,
  int xtype,
  ByteArray blinding,
  Pointer<ExternError> err,
);

/// Native function signature for setting the signature in a BBS+ proof creation context.
typedef bbs_create_proof_context_set_signature_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for setting the signature in a BBS+ proof creation context.
typedef BbsCreateProofContextSetSignature = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Native function signature for setting the nonce bytes in a BBS+ proof creation context.
typedef bbs_create_proof_context_set_nonce_bytes_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for setting the nonce bytes in a BBS+ proof creation context.
typedef BbsCreateProofContextSetNonceBytes = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Native function signature for setting the public key in a BBS+ proof creation context.
typedef bbs_create_proof_context_set_public_key_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for setting the public key in a BBS+ proof creation context.
typedef BbsCreateProofContextSetPublicKey = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

/// Native function signature for generating a BLS G2 keypair.
typedef BlsGenerateG2KeyNative = Int32 Function(
  ByteArray seed,
  Pointer<ByteBuffer> publicKey,
  Pointer<ByteBuffer> secretKey,
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for generating a BLS G2 keypair.
typedef BlsGenerateG2Key = int Function(
  ByteArray seed,
  Pointer<ByteBuffer> publicKey,
  Pointer<ByteBuffer> secretKey,
  Pointer<ExternError> err,
);

/// Native function signature for converting a BLS public key to a BBS+ public key.
typedef bls_public_key_to_bbs_key_native = Int32 Function(
  ByteArray dPublicKey,
  Uint32 messageCount,
  Pointer<ByteBuffer> publicKeyOut,
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for converting a BLS public key to a BBS+ public key.
typedef BlsPublicKeyToBbsKey = int Function(
  ByteArray dPublicKey,
  int messageCount,
  Pointer<ByteBuffer> publicKeyOut,
  Pointer<ExternError> err,
);

/// Native function signature for initializing a BBS+ proof context.
typedef bbs_create_proof_context_init_native = Uint64 Function(
  Pointer<ExternError> err,
);

/// Dart-friendly typedef for initializing a BBS+ proof context.
typedef BbsCreateProofContextInit = int Function(
  Pointer<ExternError> err,
);
