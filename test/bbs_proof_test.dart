import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:bs58/bs58.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/bbs/bbs.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_bindings.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_types.dart';
import 'package:zetrix_vc_flutter/bbs/load_library.dart';
import 'package:zetrix_vc_flutter/src/models/bbs/proof_message.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';

void main() {
  final bbs = BbsBindings(loadBbsLib());

  test('Generate BLS G2 keypair', () {
    final seedBytes = Uint8List.fromList(utf8
        .encode("privBydWNHrVd66cpkpXRB4TRxtHdruXhh5mBDUrno16e2BwLBvvH6ca"));
    final seed = ByteArray.fromUint8List(seedBytes);

    final pubKeyPtr = calloc<ByteBuffer>();
    final secKeyPtr = calloc<ByteBuffer>();
    final errPtr = calloc<ExternError>();

    final result = bbs.blsGenerateG2Key(seed, pubKeyPtr, secKeyPtr, errPtr);

    expect(result, equals(0), reason: "bls_generate_g2_key should return 0");
    expect(errPtr.ref.code, equals(0), reason: "Error code should be 0");

    final publicKey = pubKeyPtr.ref.toUint8List();
    final secretKey = secKeyPtr.ref.toUint8List();

    Tools.logDebug("Public Key: $publicKey");
    Tools.logDebug("Secret Key: $secretKey");

    final pubKeyBase58 = base58.encode(publicKey);
    Tools.logDebug('Public Key (base58): $pubKeyBase58');
    final secKeyBase58 = base58.encode(secretKey);
    Tools.logDebug('Secret Key (base58): $secKeyBase58');

    // Cleanup
    calloc.free(seed.data);
    calloc.free(pubKeyPtr);
    calloc.free(secKeyPtr);
    calloc.free(errPtr);
  });

  test('Create blsPublicToBbsPublicKey', () async {
    final bbs = Bbs();
    final publicKeyMultiBasePlain =
        'zmGHfsGYtRbh6MfDQegV976maR1FwAJxFnboew8wydSVd2YwprnhXQvBDUYnQ13PCeifouGzeecE3dko8F6KTEGkZtuDFLBYfAJHSCzpk9ukfXWqX9ykpz326RSWPxjeagQp';
    final bbsPubkey = bbs.blsPublicToBbsPublicKey(
        base58.decode(publicKeyMultiBasePlain.substring(1)), 2);

    Tools.logDebug('bbsPubKey: $bbsPubkey');
    expect(bbsPubkey, isNotEmpty);
  });

  test('Create BBS+ proof', () async {
    final bbs = Bbs();

    final publicKey = Uint8List.fromList([
      173,
      243,
      224,
      225,
      156,
      135,
      58,
      23,
      194,
      224,
      120,
      187,
      25,
      199,
      10,
      185,
      180,
      20,
      85,
      28,
      45,
      83,
      189,
      199,
      189,
      174,
      95,
      255,
      203,
      17,
      164,
      88,
      213,
      83,
      4,
      232,
      249,
      211,
      232,
      176,
      92,
      213,
      176,
      36,
      226,
      107,
      235,
      90,
      22,
      92,
      215,
      204,
      5,
      238,
      234,
      250,
      6,
      172,
      94,
      85,
      95,
      9,
      245,
      32,
      160,
      13,
      83,
      166,
      75,
      98,
      33,
      142,
      10,
      185,
      186,
      81,
      44,
      168,
      107,
      4,
      146,
      226,
      60,
      100,
      123,
      17,
      29,
      116,
      185,
      220,
      128,
      26,
      82,
      128,
      73,
      66
    ]);

    final signature = Uint8List.fromList([
      178,
      3,
      47,
      19,
      233,
      79,
      248,
      129,
      96,
      125,
      19,
      203,
      52,
      90,
      160,
      8,
      130,
      163,
      230,
      93,
      99,
      141,
      2,
      96,
      175,
      235,
      106,
      113,
      125,
      39,
      154,
      21,
      175,
      238,
      179,
      236,
      27,
      229,
      208,
      66,
      243,
      5,
      31,
      185,
      101,
      101,
      230,
      177,
      97,
      65,
      229,
      41,
      252,
      220,
      112,
      78,
      38,
      239,
      6,
      153,
      202,
      130,
      196,
      144,
      18,
      197,
      136,
      173,
      160,
      231,
      132,
      54,
      139,
      224,
      157,
      181,
      128,
      96,
      13,
      217,
      20,
      14,
      202,
      20,
      45,
      32,
      76,
      112,
      125,
      76,
      192,
      97,
      240,
      118,
      55,
      215,
      166,
      87,
      69,
      52,
      90,
      199,
      23,
      31,
      200,
      2,
      242,
      213,
      158,
      44,
      158,
      49
    ]);
    final nonce = Uint8List.fromList("nonce".codeUnits);

    final messages = [
      ProofMessage(
        1, // Revealed
        Uint8List.fromList(utf8.encode("message1")),
        Uint8List(0),
      ),
      ProofMessage(
        2, // Revealed
        Uint8List.fromList(utf8.encode("message2")),
        Uint8List(0),
      ),
    ];

    try {
      final proof = await bbs.blsCreateProofFFI(
        publicKey: publicKey,
        nonce: nonce,
        signature: signature,
        messages: messages,
      );

      Tools.logDebug('✅ Proof generated: ${proof.length} bytes');
      Tools.logDebug('✅ Proof bytes: $proof');
      Tools.logDebug(
          'Proof (hex): ${proof.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
      expect(proof, isA<Uint8List>());
    } catch (e, stack) {
      Tools.logDebug('❌ Error during proof generation: $e');
      Tools.logDebug('📌 Stacktrace:\n$stack');
      fail('Proof generation failed');
    }
  });
}
