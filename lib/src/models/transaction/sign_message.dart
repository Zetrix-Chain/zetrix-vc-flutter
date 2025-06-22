import 'package:json_annotation/json_annotation.dart';

part 'sign_message.g.dart';

/// A model representing a signed message, typically used for operations
/// requiring cryptographic signatures along with a public key.
///
/// This class can serialize and deserialize from JSON, enabling easy interaction
/// with APIs or systems that require signed data.
///
/// **Key Properties:**
/// - [signData]: The signed message or data in string format.
/// - [publicKey]: The public key corresponding to the private key that created the signature.
@JsonSerializable(explicitToJson: true)
class SignMessage {
  /// The signed data or message.
  ///
  /// This property holds the actual signed content in string format, typically
  /// produced by cryptographic signing algorithms.
  String? signData;

  /// The public key used to verify the signed data.
  ///
  /// This public key corresponds to the private key used to generate the signature.
  String? publicKey;

  /// Constructs a new instance of [SignMessage].
  ///
  /// **Parameters:**
  /// - [signData]: The signed message content.
  /// - [publicKey]: The public key used for verification.
  SignMessage({this.signData, this.publicKey});

  /// Creates a [SignMessage] object from a JSON structure.
  factory SignMessage.fromJson(Map<String, dynamic> json) =>
      _$SignMessageFromJson(json);

  /// Converts the [SignMessage] object into a JSON structure.
  Map<String, dynamic> toJson() => _$SignMessageToJson(this);
}
