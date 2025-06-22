// ignore_for_file: camel_case_types, constant_identifier_names

import 'dart:ffi';
import 'bbs_ffi_types.dart';

class BbsBindings {
  final DynamicLibrary _lib;

  BbsBindings(this._lib);

  late final BlsGenerateG2Key blsGenerateG2Key = _lib
      .lookup<NativeFunction<BlsGenerateG2KeyNative>>('bls_generate_g2_key')
      .asFunction();

  late final BlsPublicKeyToBbsKey blsPublicKeyToBbsKey = _lib
      .lookup<NativeFunction<bls_public_key_to_bbs_key_native>>(
          'bls_public_key_to_bbs_key')
      .asFunction();

  late final BbsCreateProofContextInit bbsCreateProofContextInit = _lib
      .lookup<NativeFunction<bbs_create_proof_context_init_native>>(
          'bbs_create_proof_context_init')
      .asFunction();

  late final BbsCreateProofContextSetPublicKey
      bbsCreateProofContextSetPublicKey = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_public_key_native>>(
            'bbs_create_proof_context_set_public_key',
          )
          .asFunction();

  late final BbsCreateProofContextSetNonceBytes
      bbsCreateProofContextSetNonceBytes = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_nonce_bytes_native>>(
            'bbs_create_proof_context_set_nonce_bytes',
          )
          .asFunction();

  late final BbsCreateProofContextSetSignature
      bbsCreateProofContextSetSignature = _lib
          .lookup<
              NativeFunction<bbs_create_proof_context_set_signature_native>>(
            'bbs_create_proof_context_set_signature',
          )
          .asFunction();

  late final BbsCreateProofContextAddProofMessageBytes
      bbsCreateProofContextAddProofMessageBytes = _lib
          .lookup<
              NativeFunction<
                  bbs_create_proof_context_add_proof_message_bytes_native>>(
            'bbs_create_proof_context_add_proof_message_bytes',
          )
          .asFunction();

  late final BbsCreateProofContextFinish bbsCreateProofContextFinish = _lib
      .lookup<NativeFunction<bbs_create_proof_context_finish_native>>(
        'bbs_create_proof_context_finish',
      )
      .asFunction();

  late final BbsCreateProofContextSize bbsCreateProofContextSize = _lib
      .lookup<NativeFunction<bbs_create_proof_context_size_native>>(
          'bbs_create_proof_context_size')
      .asFunction();
}

typedef bbs_create_proof_context_size_native = Int32 Function(Uint64 handle);

typedef BbsCreateProofContextSize = int Function(int handle);

typedef bbs_create_proof_size_native = Int32 Function(Uint64 handle);

typedef BbsCreateProofSize = int Function(int handle);

typedef bbs_create_proof_context_finish_native = Int32 Function(
  Uint64 handle,
  Pointer<ByteBuffer> proof,
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextFinish = int Function(
  int handle,
  Pointer<ByteBuffer> proof,
  Pointer<ExternError> err,
);

typedef bbs_create_proof_context_add_proof_message_bytes_native = Int32
    Function(
  Uint64 handle,
  ByteArray message,
  Int32 xtype,
  ByteArray blinding,
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextAddProofMessageBytes = int Function(
  int handle,
  ByteArray message,
  int xtype,
  ByteArray blinding,
  Pointer<ExternError> err,
);

typedef bbs_create_proof_context_set_signature_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextSetSignature = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef bbs_create_proof_context_set_nonce_bytes_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextSetNonceBytes = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef bbs_create_proof_context_set_public_key_native = Int32 Function(
  Uint64 handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextSetPublicKey = int Function(
  int handle,
  ByteArray value,
  Pointer<ExternError> err,
);

typedef BlsGenerateG2KeyNative = Int32 Function(
  ByteArray seed,
  Pointer<ByteBuffer> publicKey,
  Pointer<ByteBuffer> secretKey,
  Pointer<ExternError> err,
);

typedef BlsGenerateG2Key = int Function(
  ByteArray seed,
  Pointer<ByteBuffer> publicKey,
  Pointer<ByteBuffer> secretKey,
  Pointer<ExternError> err,
);

typedef bls_public_key_to_bbs_key_native = Int32 Function(
  ByteArray dPublicKey,
  Uint32 messageCount,
  Pointer<ByteBuffer> publicKeyOut,
  Pointer<ExternError> err,
);

typedef BlsPublicKeyToBbsKey = int Function(
  ByteArray dPublicKey,
  int messageCount,
  Pointer<ByteBuffer> publicKeyOut,
  Pointer<ExternError> err,
);

typedef bbs_create_proof_context_init_native = Uint64 Function(
  Pointer<ExternError> err,
);

typedef BbsCreateProofContextInit = int Function(
  Pointer<ExternError> err,
);
