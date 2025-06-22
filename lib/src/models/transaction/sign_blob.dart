import 'package:json_annotation/json_annotation.dart';

part 'sign_blob.g.dart';

/// A model representing a signed binary object (blob), typically used in cryptographic operations
/// where binary data is signed along with the public key.
///
/// This class supports JSON serialization and deserialization, making it easy to interact with APIs
/// or systems that require signed blobs.
///
/// **Key Properties:**
/// - [signBlob]: The signed binary data, encoded as a string.
/// - [publicKey]: The public key associated with the private key that signed the blob.
@JsonSerializable(explicitToJson: true)
class SignBlob {
  /// The signed binary data in string format.
  ///
  /// This property contains the actual signed content, often encoded in Base64 or a similar format.
  String? signBlob;

  /// The public key used to verify the signed blob.
  ///
  /// This public key corresponds to the private key that was used to generate the signature.
  String? publicKey;

  /// Constructs a new instance of [SignBlob].
  ///
  /// **Parameters:**
  /// - [signBlob]: The signed binary object, as a string.
  /// - [publicKey]: The public key used to verify the signature.
  SignBlob({this.signBlob, this.publicKey});

  /// Creates a [SignBlob] object from a JSON structure.
  factory SignBlob.fromJson(Map<String, dynamic> json) =>
      _$SignBlobFromJson(json);

  /// Converts the [SignBlob] object into a JSON structure.
  Map<String, dynamic> toJson() => _$SignBlobToJson(this);
}
