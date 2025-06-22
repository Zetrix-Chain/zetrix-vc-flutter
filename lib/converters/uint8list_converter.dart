import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

/// A custom JSON converter for encoding and decoding `Uint8List` objects to and from base64 strings.
///
/// The `Uint8ListBase64Converter` class implements the `JsonConverter` interface,
/// allowing seamless serialization and deserialization of `Uint8List` objects within
/// models that use the `json_serializable` package.
///
/// This is particularly useful for handling binary data (e.g., image bytes or cryptographic keys)
/// in a way that's human-readable and safe to transmit over JSON.

class Uint8ListBase64Converter implements JsonConverter<Uint8List?, String?> {
  /// Creates a constant instance of `Uint8ListBase64Converter`.
  const Uint8ListBase64Converter();

  /// Converts a JSON base64-encoded [String] to a [Uint8List].
  ///
  /// This method decodes a base64 [String?] into a [Uint8List?].
  @override
  Uint8List? fromJson(String? json) => json == null ? null : base64Decode(json);

  /// Converts a [Uint8List] into a base64-encoded [String].
  ///
  /// This method encodes a [Uint8List?] into a base64 [String?].
  @override
  String? toJson(Uint8List? object) =>
      object == null ? null : base64Encode(object);
}
