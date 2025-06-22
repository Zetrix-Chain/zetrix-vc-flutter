import 'package:collection/collection.dart';

/// An enumeration representing different types of cryptographic proofs.
///
/// Each enum value corresponds to a specific type of proof method used for
/// verifying credentials or data integrity. This includes methods like
/// Ed25519 signature, BBS+ signatures, and Bulletproof range proofs.
enum ProofTypeEnum {
  /// Ed25519 signature type (code: 0, value: "Ed25519Signature2020").
  ed25519(0, 'Ed25519Signature2020'),

  /// BBS+ signature type (code: 1, value: "BbsBlsSignature2020").
  bbsSign(1, 'BbsBlsSignature2020'),

  /// BBS+ selective disclosure proof (code: 2, value: "BbsBlsSignatureProof2020").
  bbsProof(2, 'BbsBlsSignatureProof2020'),

  /// Bulletproof range proof type (code: 3, value: "BulletproofRangeProof2021").
  bulletproof(3, 'BulletproofRangeProof2021');

  /// Numeric code representing the proof type.
  final int code;

  /// String value representing the proof type.
  final String value;

  /// Private constructor to assign the [code] and [value] to the enum.
  const ProofTypeEnum(this.code, this.value);

  /// Retrieves a [ProofTypeEnum] instance from its numeric [code].
  static ProofTypeEnum? fromCode(int code) {
    return ProofTypeEnum.values.firstWhereOrNull((e) => e.code == code);
  }

  /// Retrieves a [ProofTypeEnum] instance from its string [value].
  static ProofTypeEnum? fromValue(String value) {
    return ProofTypeEnum.values.firstWhereOrNull((e) => e.value == value);
  }
}
