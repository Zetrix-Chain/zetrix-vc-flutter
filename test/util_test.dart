import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  test('test gasToUGas', () async {
    String result = Helpers.gasToUGas('123.12312312');
    expect(result, isNot(''));

    result = Helpers.gasToUGas('0.12312312');
    expect(result, isNot(''));

    result = Helpers.gasToUGas('123');
    expect(result, isNot(''));

    result = Helpers.gasToUGas('123.123123123');
    expect(result, '');

    result = Helpers.gasToUGas('-1');
    expect(result, '');

    result = Helpers.gasToUGas('abc');
    expect(result, '');
  });

  test('test ugasToGas', () async {
    String result = Helpers.ugasToGas('123.12312312');
    expect(result, '');

    result = Helpers.ugasToGas('0.12312312');
    expect(result, '');

    result = Helpers.ugasToGas('123');
    expect(result, isNot(''));

    result = Helpers.ugasToGas('-1');
    expect(result, '');

    result = Helpers.ugasToGas('abc');
    expect(result, '');
  });

  test('test unitWithDecimals', () async {
    String result = Helpers.unitWithDecimals('1', '6');
    expect(result, '1000000');

    result = Helpers.unitWithDecimals('0.12312312', '6');
    expect(result, '');

    result = Helpers.unitWithDecimals('1', '0.6');
    expect(result, '');
  });
}
