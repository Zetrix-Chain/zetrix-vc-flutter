import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:convert/convert.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';

/// A utility class for encoding, decoding, and compressing string data.
///
/// Includes functions for converting between UTF-8 and hexadecimal representations,
/// and compressing JSON strings using GZIP.
class EncodingUtils {
  /// Converts a UTF-8 encoded string to its hexadecimal representation.
  static String utfToHex(String str) {
    if (Tools.isEmptyString(str)) {
      return '';
    }

    var encoded = utf8.encode(str);
    return encoded.map((e) => e.toRadixString(16)).join();
  }

  /// Converts a hexadecimal string to its UTF-8 representation.
  static String hexToUtf(String str) {
    final regex = RegExp(r"^[0-9a-fA-F]+$");
    if (Tools.isEmptyString(str) || !regex.hasMatch(str)) {
      return '';
    }

    var encoded = hex.decode(str);
    return utf8.decode(encoded);
  }

  /// Compresses a JSON string [jsonStr] using GZIP and returns the compressed bytes as a [Uint8List].
  ///
  /// This method encodes the input JSON string as UTF-8 and then compresses it
  /// using the GZIP algorithm. This is useful for minimizing data size for transmission
  /// or storage.
  ///
  /// Returns: A [Uint8List] containing the GZIP-compressed data.
  static Uint8List compressJsonGzip(String jsonStr) {
    final jsonString = json.encode(jsonStr);
    final inputBytes = utf8.encode(jsonString);

    final compressed = GZipEncoder().encode(inputBytes);
    return Uint8List.fromList(compressed);
  }
}
