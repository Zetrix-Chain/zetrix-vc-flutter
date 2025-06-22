import 'dart:math';

import 'dart:convert' show jsonEncode, jsonDecode;
import 'tools.dart';

class Helpers {
  static String gasToUGas(String gas) {
    if (!Tools.isAvailableZTX(gas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(gas) * oneMo).toString();
  }

  static String ugasToGas(String ugas) {
    if (!Tools.isAvailableValue(ugas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(ugas) / oneMo).toString();
  }

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
