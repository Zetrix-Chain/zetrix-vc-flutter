import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinenacl/ed25519.dart' as nacl;
import "package:hex/hex.dart";
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  EncryptionUtils encryption = EncryptionUtils();
  test('Generate keypair', () async {
    // final keyPair = EncryptionUtils();
    CreateAccount keypair = await encryption.generateKeyPair();

    assert(keypair.address is String);
    assert(keypair.address is String);
    assert(keypair.address is String);
  });

  test('EncryptionUtils from seed', () async {
    EncryptionUtils encryption = EncryptionUtils();
    String pubKey = await encryption.getEncPublicKey(
        'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo');

    Tools.logDebug(pubKey);

    expect(pubKey,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');
  });

  test('Get address from public key', () async {
    EncryptionUtils encryption = EncryptionUtils();
    String address = encryption.getAddress(
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');

    expect(address, 'ZTX3Wk4JiwggfZquiTgj4KwY6wNRFNVTrbgxe');
  });

  test('Check address validation', () async {
    EncryptionUtils keypair = EncryptionUtils();
    bool valid = keypair.checkAddress('ZTX3Wk4JiwggfZquiTgj4KwY6wNRFNVTrbgxe');

    expect(valid, true);
  });

  test('Sign message', () async {
    SignMessage resp = await encryption.signMessage(
        "testABC", 'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo');

    expect(resp, isNot(null));
  });

  test('Verify message validation', () async {
    EncryptionUtils keypair = EncryptionUtils();

    List<int> signatureByte = HEX.decode(
        '6bf8535d178011a1f361afdb21d43940010418caea83368ac48477c5c2302ede0436ca90599237b3adf02698b2f96348ea397e125909b9ed201d055ab241290d');
    Tools.logDebug(signatureByte);
    List<int> messageByte = utf8.encode('43556C34');
    bool valid = await keypair.verify(signatureByte, messageByte,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');
    Tools.logDebug(valid);

    expect(valid, true);
  });

  test('Pinenacl sign and verify', () {
    String message = '71413349';
    List<int> msg = message.codeUnits;
    Uint8List msgByte = Uint8List.fromList(msg);
    nacl.SignedMessage sig = encryption.naclSign(
        'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo', msgByte);

    Tools.logDebug('Signature Hex: ${HEX.encode(sig.signature)}');

    bool valid = encryption.naclVerify(sig.signature, msgByte,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');

    expect(valid, true);
  });
}
