import 'package:zetrix_vc_flutter/src/models/account/account_valid.dart';
import 'package:zetrix_vc_flutter/src/models/account/create_account.dart';
import 'package:zetrix_vc_flutter/src/utils/encryption_utils.dart';
import 'package:zetrix_vc_flutter/src/models/sdk_result.dart';
import 'package:zetrix_vc_flutter/src/models/sdk_exceptions.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';

/// A service class for handling account-related operations in the Zetrix SDK.
///
/// This class provides functionalities for creating accounts and validating addresses.
class ZetrixAccountService {
  /// Creates a new instance of [ZetrixAccountService].
  ZetrixAccountService();

  /// Generates a new Zetrix account.
  ///
  /// This method uses [EncryptionUtils] to generate a cryptographic key pair
  /// required for creating a new Zetrix account.
  Future<ZetrixSDKResult<CreateAccount>> createAccount() async {
    try {
      EncryptionUtils encryption = EncryptionUtils();
      CreateAccount keyPair = await encryption.generateKeyPair();
      return ZetrixSDKResult.success(data: keyPair);
    } catch (e) {
      Tools.logDebug(e);
      return ZetrixSDKResult.failure(
          error: DefaultError('Keypair creation failed'));
    }
  }

  /// Validates a given Zetrix account address.
  ///
  /// This method checks if the provided account [address] is valid using [EncryptionUtils].
  Future<ZetrixSDKResult<AccountValid>> validateAccount(String address) async {
    if (Tools.isEmptyString(address)) {
      return const ZetrixSDKResult.failure(error: BadRequest());
    }

    AccountValid resp = AccountValid();

    EncryptionUtils encryption = EncryptionUtils();

    resp.isValid = encryption.checkAddress(address);

    return ZetrixSDKResult.success(data: resp);
  }
}
