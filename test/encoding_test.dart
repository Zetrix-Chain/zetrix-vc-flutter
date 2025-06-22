import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/src/utils/encoding_utils.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  test('test unitWithDecimals', () async {
    String result = Helpers.unitWithDecimals('1', '6');
    expect(result, '1000000');

    result = Helpers.unitWithDecimals('0.12312312', '6');
    expect(result, '');

    result = Helpers.unitWithDecimals('1', '0.6');
    expect(result, '');
  });

  test('test utfToHex', () async {
    String result = EncodingUtils.utfToHex('hello, world');
    expect(result, '68656c6c6f2c20776f726c64');

    result = EncodingUtils.utfToHex('');
    expect(result, '');
  });

  test('test hexToUtf', () async {
    String result = EncodingUtils.hexToUtf('68656c6c6f2c20776f726c64');
    expect(result, 'hello, world');

    result = EncodingUtils.hexToUtf('asdas');
    expect(result, '');

    result = EncodingUtils.hexToUtf('');
    expect(result, '');
  });
}
