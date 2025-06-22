import 'dart:math';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'tools.dart';

/// A utility class that provides helper methods for various SDK-related operations.
///
/// The `Helpers` class includes methods for conversions between gas and micro-gas (ugas),
/// handling numbers with decimal places, and extracting minimal verifiable presentations.
///
class Helpers {
  /// Converts a gas amount represented as a [String] to its equivalent micro-gas (ugas) value.
  static String gasToUGas(String gas) {
    if (!Tools.isAvailableZTX(gas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(gas) * oneMo).toString();
  }

  /// Converts a micro-gas (ugas) value represented as a [String] to its equivalent gas value.
  static String ugasToGas(String ugas) {
    if (!Tools.isAvailableValue(ugas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(ugas) / oneMo).toString();
  }

  /// Multiplies the given [amount] with 10 raised to the power of [decimal].
  static String unitWithDecimals(String amount, String decimal) {
    final regex = RegExp(r"^[0-9]+$");

    if (!regex.hasMatch(amount) || !regex.hasMatch(decimal)) {
      return '';
    }
    num oneMo = pow(10, int.parse(decimal));
    num amountWithDecimals = num.parse(amount) * oneMo;
    if (amountWithDecimals >= 0 && amountWithDecimals <= double.maxFinite) {
      return amountWithDecimals.toString();
    }
    return '';
  }

  /// Extracts a minimal verifiable presentation (VP) from the given [vpJson].
  static String extractMinimalVp(String vpJson) {
    final fullVp = jsonDecode(vpJson) as Map<String, dynamic>;

    final holder = fullVp['holder'];
    final vcList = fullVp['verifiableCredential'] as List<dynamic>;
    final originalVc = vcList.first as Map<String, dynamic>;

    final minimalProof = (originalVc['proof'] as List)
        .where((p) => p['type'] == 'BbsBlsSignatureProof2020')
        .map((p) => {
              'type': p['type'],
              'proofValue': p['proofValue'],
              'verificationMethod': p['verificationMethod'],
              'nonce': p['nonce'],
            })
        .toList();

    final minimalVc = {
      'id': originalVc['id'],
      'issuer': originalVc['issuer'],
      'expirationDate': originalVc['expirationDate'],
      'credentialSubject': originalVc['credentialSubject'],
      'proof': minimalProof,
    };

    return jsonEncode({
      'holder': holder,
      'verifiableCredential': [minimalVc],
    });
  }
}
