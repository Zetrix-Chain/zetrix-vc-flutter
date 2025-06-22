import 'package:flutter/services.dart';
import '../src/models/bbs/proof_message.dart';

class BbsFlutter {
  static const MethodChannel _channel = MethodChannel('bbs_flutter');

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

  static Future<Uint8List> blsPublicToBbsPublicKey(
      {required Uint8List blsPublicKey, required int messages}) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
        'blsPublicToBbsPublicKey',
        {'blsPublicKey': blsPublicKey, 'messages': messages});

    return Uint8List.fromList(result!.cast<int>());
  }
}
