/// A utility class that provides constants related to Verifiable Credentials (VC)
/// and Verifiable Presentations (VP) as defined by the W3C Verifiable Credentials standard.
///
/// This class contains predefined context URIs, types, and proof purposes
/// that are commonly used when working with VC/VP.
class VcConstant {
  /// A list of JSON-LD contexts used for Verifiable Credentials (VC) and Verifiable Presentations (VP).
  ///
  /// **Contexts:**
  /// - `'https://www.w3.org/2018/credentials/v1'`: Defines the core VC structure and terms.
  /// - `'https://w3id.org/security/bbs/v1'`: Defines security terms, including support for BBS+ signatures.
  static const List<String> context = [
    'https://www.w3.org/2018/credentials/v1',
    'https://w3id.org/security/bbs/v1',
  ];

  /// The type identifier for a Verifiable Credential (VC).
  ///
  /// Used to indicate that an object represents a Verifiable Credential.
  /// Commonly included as a type in VC documents.
  static const String typeVc = 'VerifiableCredential';

  /// The type identifier for a Verifiable Presentation (VP).
  ///
  /// Used to indicate that an object represents a Verifiable Presentation.
  /// Commonly included as a type in VP documents.
  static const String typeVp = 'VerifiablePresentation';

  /// Proof purpose constant for "assertionMethod".
  ///
  /// **Usage:**
  /// - Indicates that the proof was created to assert the veracity of the credential it is associated with.
  /// - Commonly included in proofs for Verifiable Credentials.
  static const String proofPurposeAssert = 'assertionMethod';

  /// Proof purpose constant for "authentication".
  ///
  /// **Usage:**
  /// - Indicates that the proof was created for authentication purposes, typically
  ///   to verify the identity of the entity presenting the credential or presentation.
  /// - Commonly included in proofs for Verifiable Presentations.
  static const String proofPurposeAuth = 'authentication';
}
