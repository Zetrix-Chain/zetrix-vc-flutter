import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final account = ZetrixAccountService();

  var userAccount = {"address": "", "pubKey": "", "privKey": ""};

  test('Create account', () async {
    CreateAccount? finalResp;
    ZetrixSDKResult<CreateAccount> resp = await account.createAccount();

    if (resp is Success<CreateAccount> && resp.data != null) {
      finalResp = resp.data;
      Tools.logDebug(finalResp!.toJson().toString());
      userAccount["address"] = finalResp.address!;
      userAccount["pubKey"] = finalResp.publicKey!;
      userAccount["privKey"] = finalResp.privateKey!;
      userAccount["did"] = finalResp.did!;
    } else if (resp is Failure) {
      finalResp = null;
    }

    expect(finalResp, isNotNull);
  });
}
