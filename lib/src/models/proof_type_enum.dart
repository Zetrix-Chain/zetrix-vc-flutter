import 'package:collection/collection.dart';

enum ProofTypeEnum {
  ed25519(0, 'Ed25519Signature2020'),
  bbsSign(1, 'BbsBlsSignature2020'),
  bbsProof(2, 'BbsBlsSignatureProof2020'),
  bulletproof(3, 'BulletproofRangeProof2021');

  final int code;
  final String value;

  const ProofTypeEnum(this.code, this.value);

  static ProofTypeEnum? fromCode(int code) {
    return ProofTypeEnum.values.firstWhereOrNull((e) => e.code == code);
  }

  static ProofTypeEnum? fromValue(String value) {
    return ProofTypeEnum.values.firstWhereOrNull((e) => e.value == value);
  }
}
