import 'package:flutter/services.dart';
import 'package:zetrix_vc_flutter/src/models/bbs/proof_message.dart';

/// A Flutter plugin for working with cryptographic operations in BBS signature schemes.
///
/// The `BbsFlutter` class acts as a bridge between Flutter code and the native platform implementations
/// (through the `MethodChannel`). It provides cryptographic utilities for managing keys, creating proofs,
/// and working directly with BLS and BBS public keys in the context of BBS+ signatures.

class BbsFlutter {
  /// A [MethodChannel] used to communicate with the native platform for cryptographic operations.
  static const MethodChannel _channel = MethodChannel('bbs_flutter');

  /// Generates a BLS12-381 G1 key pair for use with BBS+ signatures.
  ///
  /// This method generates both the public key and the secret key using a provided cryptographic seed.
  static Future<Map<String, Uint8List>> generateBls12381G1Key(
      Uint8List seed) async {
    final result = await _channel.invokeMethod('generateBls12381G1Key', {
      'seed': seed,
    });

    return {
      'publicKey': Uint8List.fromList(List<int>.from(result['publicKey'])),
      'secretKey': Uint8List.fromList(List<int>.from(result['secretKey'])),
    };
  }

  /// Creates a zero-knowledge proof using BBS+.
  static Future<Uint8List> createProof({
    required Uint8List publicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<Map<String, dynamic>> messages,
  }) async {
    final result = await _channel.invokeMethod('createProof', {
      'publicKey': publicKey,
      'nonce': nonce,
      'signature': signature,
      'messages': messages,
    });

    return Uint8List.fromList(List<int>.from(result));
  }

  /// Creates a zero-knowledge proof using BLS with specified [ProofMessage] objects.
  static Future<Uint8List> blsCreateProof({
    required Uint8List publicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<ProofMessage> messages,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'blsCreateProof',
      {
        'publicKey': publicKey,
        'nonce': nonce,
        'signature': signature,
        'messages': messages.map((m) => m.toJson()).toList(),
      },
    );

    return Uint8List.fromList(result!.cast<int>());
  }

  /// Converts a BLS12-381 public key to a BBS+ public key for a given number of messages.
  static Future<Uint8List> blsPublicToBbsPublicKey(
      {required Uint8List blsPublicKey, required int messages}) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
        'blsPublicToBbsPublicKey',
        {'blsPublicKey': blsPublicKey, 'messages': messages});

    return Uint8List.fromList(result!.cast<int>());
  }
}
