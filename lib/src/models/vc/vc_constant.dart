class VcConstant {
  /// Context list used for VC/VP
  static const List<String> context = [
    'https://www.w3.org/2018/credentials/v1',
    'https://w3id.org/security/bbs/v1',
  ];

  static const String typeVc = 'VerifiableCredential';
  static const String typeVp = 'VerifiablePresentation';

  static const String proofPurposeAssert = 'assertionMethod';
  static const String proofPurposeAuth = 'authentication';
}
