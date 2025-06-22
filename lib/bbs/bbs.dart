import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_bindings.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_types.dart';
import 'package:zetrix_vc_flutter/bbs/load_library.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';
import 'package:zetrix_vc_flutter/src/utils/encryption_utils.dart';
import 'package:zetrix_vc_flutter/src/utils/generator_utils.dart';
import 'bbs_flutter.dart';
import '../src/models/bbs/proof_message.dart';

class Bbs {
  final bbs = BbsBindings(loadBbsLib());
  EncryptionUtils encryption = EncryptionUtils();

  Future<Uint8List> blsCreateProofFFI({
    required Uint8List publicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<ProofMessage> messages,
  }) {
    // Convert publickey bls to bbs
    final bbsPublicKey = blsPublicToBbsPublicKey(publicKey, messages.length);
    print('bbsPublicKey length = ${bbsPublicKey.length}');

    print('BBS public key (base64): ${base64.encode(bbsPublicKey)}');

    final err1 = calloc<ExternError>();
    final handle = bbs.bbsCreateProofContextInit(err1);
    print('handle init: $handle');
    if (handle == 0) {
      throw Exception('Unable to create proof context');
    }
    calloc.free(err1);

    final publicKeyPtr = ByteArrayHelper.allocate(bbsPublicKey);

    final err2 = calloc<ExternError>();

    final result = bbs.bbsCreateProofContextSetPublicKey(
      handle,
      publicKeyPtr.ref,
      err2,
    );
    print('result bbsCreateProofContextSetPublicKey: $result');

    calloc.free(publicKeyPtr.ref.data);
    calloc.free(publicKeyPtr);

    if (result != 0) {
      throwIfError(result, err2, 'Unable to set public key');
    }

    calloc.free(err2);

    final noncePtr = ByteArrayHelper.allocate(nonce); // nonce is Uint8List
    final err3 = calloc<ExternError>();

    final result1 = bbs.bbsCreateProofContextSetNonceBytes(
      handle,
      noncePtr.ref,
      err3,
    );
    print('result bbsCreateProofContextSetNonceBytes: $result1');

    calloc.free(noncePtr.ref.data);
    calloc.free(noncePtr);

    if (result1 != 0) {
      throwIfError(result1, err3, 'Unable to set nonce');
    }

    calloc.free(err3);

    final sigPtr = ByteArrayHelper.allocate(signature); // signature: Uint8List
    final err4 = calloc<ExternError>();

    final result2 = bbs.bbsCreateProofContextSetSignature(
      handle,
      sigPtr.ref,
      err4,
    );
    print('result bbsCreateProofContextSetSignature: $result2');

    calloc.free(sigPtr.ref.data);
    calloc.free(sigPtr);

    if (result2 != 0) {
      throwIfError(result2, err4, 'Unable to set signature');
    }

    calloc.free(err4);

    final err5 = calloc<ExternError>();

    for (final msg in messages) {
      final msgPtr = ByteArrayHelper.allocate(msg.message);
      final blindPtr = ByteArrayHelper.allocate(msg.blindingFactor);

      final result3 = bbs.bbsCreateProofContextAddProofMessageBytes(
        handle,
        msgPtr.ref,
        msg.type,
        blindPtr.ref,
        err5,
      );

      calloc.free(msgPtr.ref.data);
      calloc.free(msgPtr);
      calloc.free(blindPtr.ref.data);
      calloc.free(blindPtr);

      if (result3 != 0) {
        throwIfError(result3, err5, 'Unable to add proof message');
      }
    }

    calloc.free(err5);

    final proofSize = bbs.bbsCreateProofContextSize(handle);
    print('proofSize: $proofSize');
    if (proofSize <= 0) {
      throw Exception('Invalid proof size from bbs_create_proof_size()');
    }

    final proofPtr = calloc<ByteBuffer>();
    final err6 = calloc<ExternError>();

    final result4 = bbs.bbsCreateProofContextFinish(handle, proofPtr, err6);
    print('result bbsCreateProofContextFinish: $result4');
    if (result4 != 0) {
      calloc.free(proofPtr);
      throwIfError(result4, err6, 'Unable to create proof');
    }

    calloc.free(err6);

    final proofBytes = proofPtr.ref.data.asTypedList(proofPtr.ref.len);

    calloc.free(proofPtr);

    return Future.value(Uint8List.fromList(proofBytes));
  }

  Future<Uint8List> blsCreateProofMC({
    required Uint8List blsPublicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<ProofMessage> messages,
  }) async {
    // Convert public
    final bbsPublicKey = await BbsFlutter.blsPublicToBbsPublicKey(
      blsPublicKey: blsPublicKey,
      messages: messages.length,
    );

    print('📏 bbsPublicKey.length = ${bbsPublicKey.length}');

    print('BBS public key (base64): ${base64.encode(bbsPublicKey)}');

    final err1 = calloc<ExternError>();
    final handle = bbs.bbsCreateProofContextInit(err1);
    print('handle init: $handle');
    if (handle == 0) {
      throw Exception('Unable to create proof context');
    }
    calloc.free(err1);

    final publicKeyPtr = ByteArrayHelper.allocate(bbsPublicKey);

    final err2 = calloc<ExternError>();

    final result = bbs.bbsCreateProofContextSetPublicKey(
      handle,
      publicKeyPtr.ref,
      err2,
    );
    print('result bbsCreateProofContextSetPublicKey: $result');

    calloc.free(publicKeyPtr.ref.data);
    calloc.free(publicKeyPtr);

    if (result != 0) {
      throwIfError(result, err2, 'Unable to set public key');
    }

    calloc.free(err2);

    final noncePtr = ByteArrayHelper.allocate(nonce); // nonce is Uint8List
    final err3 = calloc<ExternError>();

    final result1 = bbs.bbsCreateProofContextSetNonceBytes(
      handle,
      noncePtr.ref,
      err3,
    );
    print('result bbsCreateProofContextSetNonceBytes: $result1');

    calloc.free(noncePtr.ref.data);
    calloc.free(noncePtr);

    if (result1 != 0) {
      throwIfError(result1, err3, 'Unable to set nonce');
    }

    calloc.free(err3);

    final sigPtr = ByteArrayHelper.allocate(signature); // signature: Uint8List
    final err4 = calloc<ExternError>();

    final result2 = bbs.bbsCreateProofContextSetSignature(
      handle,
      sigPtr.ref,
      err4,
    );
    print('result bbsCreateProofContextSetSignature: $result2');

    calloc.free(sigPtr.ref.data);
    calloc.free(sigPtr);

    if (result2 != 0) {
      throwIfError(result2, err4, 'Unable to set signature');
    }

    calloc.free(err4);

    final err5 = calloc<ExternError>();

    for (final msg in messages) {
      final msgPtr = ByteArrayHelper.allocate(msg.message);
      final blindPtr = ByteArrayHelper.allocate(msg.blindingFactor);

      final result3 = bbs.bbsCreateProofContextAddProofMessageBytes(
        handle,
        msgPtr.ref,
        msg.type,
        blindPtr.ref,
        err5,
      );

      calloc.free(msgPtr.ref.data);
      calloc.free(msgPtr);
      calloc.free(blindPtr.ref.data);
      calloc.free(blindPtr);

      if (result3 != 0) {
        throwIfError(result3, err5, 'Unable to add proof message');
      }
    }

    calloc.free(err5);

    final proofSize = bbs.bbsCreateProofContextSize(handle);
    print('proofSize: $proofSize');
    if (proofSize <= 0) {
      throw Exception('Invalid proof size from bbs_create_proof_size()');
    }

    final proofPtr = calloc<ByteBuffer>();
    final err6 = calloc<ExternError>();

    final result4 = bbs.bbsCreateProofContextFinish(handle, proofPtr, err6);
    print('result bbsCreateProofContextFinish: $result4');
    if (result4 != 0) {
      calloc.free(proofPtr);
      throwIfError(result4, err6, 'Unable to create proof');
    }

    calloc.free(err6);

    final proofBytes = proofPtr.ref.data.asTypedList(proofPtr.ref.len);

    calloc.free(proofPtr);

    return Future.value(Uint8List.fromList(proofBytes));
  }

  Future<String> createSelectiveDisclosureProofBlsFFI(
    Uint8List publicKey,
    Uint8List nonce,
    Uint8List signature,
    List<Uint8List> messages,
    Set<int> revealedIndices,
  ) {
    final proofMessages = <ProofMessage>[];

    for (int i = 0; i < messages.length; i++) {
      final type = revealedIndices.contains(i)
          ? ProofMessageType.Revealed
          : ProofMessageType.HiddenProofSpecificBlinding;

      proofMessages.add(ProofMessage(
        type,
        messages[i],
        Uint8List(0), // empty blinding factor
      ));
    }

    return Future.sync(() async {
      final proof = await blsCreateProofFFI(
        publicKey: publicKey,
        nonce: nonce,
        signature: signature,
        messages: proofMessages,
      );

      final encoded = base64Url.encode(proof).replaceAll('=', '');
      return 'u$encoded'; // prepend "u"
    });
  }

  Future<String> createSelectiveDisclosureProofBlsMC(
    Uint8List publicKey,
    Uint8List nonce,
    Uint8List signature,
    List<Uint8List> messages,
    Set<int> revealedIndices,
  ) {
    final proofMessages = <ProofMessage>[];

    for (int i = 0; i < messages.length; i++) {
      final type = revealedIndices.contains(i)
          ? ProofMessageType.Revealed
          : ProofMessageType.HiddenProofSpecificBlinding;

      proofMessages.add(ProofMessage(
        type,
        messages[i],
        Uint8List(0), // empty blinding factor
      ));
    }

    return Future.sync(() async {
      final proof = await BbsFlutter.blsCreateProof(
        publicKey: publicKey,
        nonce: nonce,
        signature: signature,
        messages: proofMessages,
      );

      final encoded = base64Url.encode(proof).replaceAll('=', '');
      return 'u$encoded'; // prepend "u"
    });
  }

  Uint8List blsPublicToBbsPublicKey(Uint8List blsPublicKey, int messageCount) {
    final seedPtr = ByteArrayHelper.allocate(blsPublicKey);
    final out = calloc<ByteBuffer>();
    final err = calloc<ExternError>();

    final result =
        bbs.blsPublicKeyToBbsKey(seedPtr.ref, messageCount, out, err);

    if (result != 0) {
      final msg = err.ref.message == nullptr
          ? 'Unknown error'
          : err.ref.message.toDartString();
      calloc.free(err);
      calloc.free(out);
      calloc.free(seedPtr.ref.data);
      calloc.free(seedPtr);
      throw Exception('blsPublicKeyToBbsKey failed: $msg');
    }

    final bbsKey = out.ref.data.asTypedList(out.ref.len);

    calloc.free(err);
    calloc.free(out);
    calloc.free(seedPtr.ref.data);
    calloc.free(seedPtr);

    return Uint8List.fromList(bbsKey);
  }

  Uint8List decodeBbsSignature(String bbsSignature) {
    final base64Body = bbsSignature.substring(1); // remove leading "u"
    final normalized =
        base64Body.padRight((base64Body.length + 3) ~/ 4 * 4, '=');
    return base64Url.decode(normalized);
  }

  // Main function
  Future<Proof> setBbsBlsProofFFI(
    List<Uint8List> messages,
    Uint8List publicKey,
    String bbsSignature,
    List<int> revealIndex,
    String id,
  ) async {
    GeneratorUtils generatorUtil = GeneratorUtils();
    final nonce = generatorUtil.generateRandomNonce(32);
    final revealIndexSet = revealIndex.toSet();

    // Decode bbsSignature (skipping first char, as in Java)
    final decodedBbsSignature =
        base64Url.decode(encryption.formatDecode(bbsSignature.substring(1)));

    String proofValue;
    try {
      proofValue = await createSelectiveDisclosureProofBlsFFI(
        publicKey,
        nonce,
        decodedBbsSignature,
        messages,
        revealIndexSet,
      );
    } catch (e) {
      throw Exception("Proof generation error: $e");
    }

    // ISO8601 UTC time
    final created = DateTime.now().toUtc().toIso8601String();

    final proof = Proof()
      ..type = "BbsBlsSignatureProof2020"
      ..created = created
      ..verificationMethod = id
      ..proofPurpose = "assertionMethod"
      ..nonce = "u${base64UrlEncode(nonce)}"
      ..proofValue = proofValue;

    return proof;
  }

  Future<Proof> setBbsBlsProofMC(
    List<Uint8List> messages,
    Uint8List publicKey,
    String bbsSignature,
    List<int> revealIndex,
    String id,
  ) async {
    GeneratorUtils generatorUtil = GeneratorUtils();
    final nonce = generatorUtil.generateRandomNonce(32);
    final revealIndexSet = revealIndex.toSet();

    // Decode bbsSignature (skipping first char, as in Java)
    final decodedBbsSignature =
        base64Url.decode(encryption.formatDecode(bbsSignature.substring(1)));

    String proofValue;
    try {
      proofValue = await createSelectiveDisclosureProofBlsMC(
        publicKey,
        nonce,
        decodedBbsSignature,
        messages,
        revealIndexSet,
      );
    } catch (e) {
      throw Exception("Proof generation error: $e");
    }

    // ISO8601 UTC time
    final created = DateTime.now().toUtc().toIso8601String();

    final proof = Proof()
      ..type = "BbsBlsSignatureProof2020"
      ..created = created
      ..verificationMethod = id
      ..proofPurpose = "assertionMethod"
      ..nonce = "u${base64UrlEncode(nonce)}"
      ..proofValue = proofValue;

    return proof;
  }

  void throwIfError(int result, Pointer<ExternError> err, String label) {
    if (result != 0) {
      final msg = err.ref.message == nullptr
          ? 'Unknown error'
          : err.ref.message.toDartString();
      calloc.free(err);
      throw Exception('$label: $msg');
    }
  }
}
