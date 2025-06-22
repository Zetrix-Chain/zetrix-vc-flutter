// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

class ProofMessage {
  static const int PROOF_MESSAGE_TYPE_REVEALED = 1;
  static const int PROOF_MESSAGE_TYPE_HIDDEN_PROOF_SPECIFIC_BLINDING = 2;
  static const int PROOF_MESSAGE_TYPE_HIDDEN_EXTERNAL_BLINDING = 3;

  final int type;
  final Uint8List message;
  final Uint8List blindingFactor;

  ProofMessage(this.type, this.message, this.blindingFactor);

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'blinding_factor': blindingFactor,
      };
}

class ProofMessageType {
  static const int Revealed = 1;
  static const int HiddenProofSpecificBlinding = 2;
  static const int HiddenExternalBlinding = 3;
}
