// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zetrix_vc_flutter/converters/uint8list_converter.dart';

part 'keypair.g.dart';

/// Represents a cryptographic key pair consisting of a public key and a secret (private) key.
///
/// The `KeyPair` class is used to manage cryptographic key pairs for secure data processes such
/// as signing, encryption, and verification. This key pair employs `Uint8List` for storing raw
/// byte data of the keys. The class supports JSON serialization and deserialization for external
/// data handling.

@JsonSerializable()
@Uint8ListBase64Converter()
class KeyPair {
  /// Private/secret key used for signing or decryption.
  final Uint8List? secretKey;

  /// Public key used for encryption or signature verification.
  final Uint8List? publicKey;

  /// Constructs a `KeyPair` with the provided [secretKey] and [publicKey].
  KeyPair({required this.secretKey, required this.publicKey});

  /// Factory constructor for creating a `KeyPair` instance from a JSON object.
  factory KeyPair.fromJson(Map<String, dynamic> json) =>
      _$KeyPairFromJson(json);

  /// Converts the `KeyPair` instance to a JSON object.
  Map<String, dynamic> toJson() => _$KeyPairToJson(this);
}
