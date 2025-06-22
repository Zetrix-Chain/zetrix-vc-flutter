import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';

/// A utility class for encoding and decoding strings between UTF-8 and hexadecimal formats.
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
}
