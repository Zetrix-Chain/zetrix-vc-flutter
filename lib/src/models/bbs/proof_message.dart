// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

/// Represents a message used in the creation of a cryptographic proof.
///
/// A `ProofMessage` contains information about the type of proof message,
/// the actual message, and an optional blinding factor used in cryptographic processes.
class ProofMessage {
  /// Proof message type: Revealed (the message is disclosed).
  static const int PROOF_MESSAGE_TYPE_REVEALED = 1;

  /// Proof message type: Hidden with proof-specific blinding.
  /// The message is obscured using internal cryptographic blinding.
  static const int PROOF_MESSAGE_TYPE_HIDDEN_PROOF_SPECIFIC_BLINDING = 2;

  /// Proof message type: Hidden with external blinding.
  /// The message is obscured using an external blinding factor.
  static const int PROOF_MESSAGE_TYPE_HIDDEN_EXTERNAL_BLINDING = 3;

  /// Type of the proof message (one of the constants defined above).
  final int type;

  /// Byte data of the actual message.
  final Uint8List message;

  /// Byte data of the blinding factor used to obscure the message.
  final Uint8List blindingFactor;

  /// Constructs a `ProofMessage` with the specified [type], [message], and [blindingFactor].
  ProofMessage(this.type, this.message, this.blindingFactor);

  /// Converts the `ProofMessage` instance into a JSON-compatible map for serialization.
  ///
  /// ### Returns:
  /// - A `Map<String, dynamic>` representation of the proof message, where:
  ///   - `'type'`: Contains the type of the message.
  ///   - `'message'`: Contains the byte representation of the message.
  ///   - `'blinding_factor'`: Contains the byte representation of the blinding factor.
  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'blinding_factor': blindingFactor,
      };
}

/// Defines constants representing the types of proof messages.
///
/// These constants are used to specify the type of a message in cryptographic proofs.
/// Each type indicates how the message is treated in cryptographic operations.
class ProofMessageType {
  /// Revealed (message is disclosed publicly in the proof).
  static const int Revealed = 1;

  /// Hidden with proof-specific blinding.
  /// The message is hidden using internal cryptographic operations specific to the proof.
  static const int HiddenProofSpecificBlinding = 2;

  /// Hidden with external blinding.
  /// The message is hidden using an externally provided blinding factor.
  static const int HiddenExternalBlinding = 3;
}
