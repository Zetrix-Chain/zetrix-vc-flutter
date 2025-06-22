import 'dart:convert';
import 'package:bs58/bs58.dart';
import 'package:zetrix_vc_flutter/src/models/proof_type_enum.dart';
import 'package:zetrix_vc_flutter/src/models/vc/vc_constant.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

class ZetrixVpService {
  EncryptionUtils encryption = EncryptionUtils();

  Future<ZetrixSDKResult<String>> createVpFFI(
      VerifiableCredential vc,
      List<String>? revealAttribute,
      String blsPublicKey,
      String publicKey) async {
    String bbsSignature = '';
    String bbsVerificationMethod = '';

    for (final proof in vc.proof ?? []) {
      if (proof.type == ProofTypeEnum.bbsSign.value) {
        bbsSignature = proof.proofValue;
        bbsVerificationMethod = proof.verificationMethod;
      }
    }

    if (revealAttribute != null &&
        revealAttribute.isNotEmpty &&
        bbsSignature.isEmpty) {
      throw ZetrixSDKResult.failure(error: DefaultError('vcUnsupportedBbs'));
    }

    final holderDid = vc.credentialSubject?['id'] as String?;

    if (holderDid == null) {
      return ZetrixSDKResult.failure(
          error: DefaultError('vcMetadataKeyIdNull'));
    }

    final vp = VerifiablePresentation(
      context: List<String>.from(VcConstant.context),
      type: [VcConstant.typeVp],
      holder: holderDid,
    );

    if (revealAttribute != null && revealAttribute.isNotEmpty) {
      // Get BBS public key
      final publicKeyBytes = base58.decode(blsPublicKey.substring(1));

      // Flatten credentialSubject into a list of string values
      final flattenedMessages =
          Tools.flattenMapToListString(vc.credentialSubject ?? {}, '');
      final messages = flattenedMessages.map((s) => utf8.encode(s)).toList();

      // Prepare map to hold selectively disclosed values
      final discloseMap = <String, dynamic>{};

      // Flatten map to get key list for index resolution
      final credentialKeys =
          Tools.flattenMapToMap(vc.credentialSubject ?? {}, '').keys.toList();

      // Collect reveal indexes
      final revealIndex = <int>[];

      for (final fullKey in revealAttribute) {
        if (!credentialKeys.contains(fullKey)) {
          throw ZetrixSDKResult.failure(
              error:
                  DefaultError('Key not found in credentialSubject: $fullKey'));
        }

        revealIndex.add(credentialKeys.indexOf(fullKey));

        final value = Tools.getNestedValue(vc.credentialSubject ?? {}, fullKey);
        Tools.insertNestedValue(discloseMap, fullKey, value);
      }

      final bbs = Bbs();

      // Generate BBS+ proof
      final proof = await bbs.setBbsBlsProofFFI(
        messages,
        publicKeyBytes,
        bbsSignature,
        revealIndex,
        bbsVerificationMethod,
      );

      // Update credentialSubject and proof
      vc.credentialSubject = discloseMap;
      vc.proof = [proof];
    }

    final vcList = <VerifiableCredential>[vc];
    vp.verifiableCredential = vcList;
    print('vp: $vp');
    return ZetrixSDKResult.success(data: encryption.encodeVpToBase64(vp));
  }

  Future<ZetrixSDKResult<String>> createVpMC(
      VerifiableCredential vc,
      List<String>? revealAttribute,
      String blsPublicKey,
      String publicKey) async {
    String bbsSignature = '';
    String bbsVerificationMethod = '';

    for (final proof in vc.proof ?? []) {
      if (proof.type == ProofTypeEnum.bbsSign.value) {
        bbsSignature = proof.proofValue;
        bbsVerificationMethod = proof.verificationMethod;
      }
    }

    if (revealAttribute != null &&
        revealAttribute.isNotEmpty &&
        bbsSignature.isEmpty) {
      throw ZetrixSDKResult.failure(error: DefaultError('vcUnsupportedBbs'));
    }

    final holderDid = vc.credentialSubject?['id'] as String?;

    if (holderDid == null) {
      return ZetrixSDKResult.failure(
          error: DefaultError('vcMetadataKeyIdNull'));
    }

    final vp = VerifiablePresentation(
      context: List<String>.from(VcConstant.context),
      type: [VcConstant.typeVp],
      holder: holderDid,
    );

    if (revealAttribute != null && revealAttribute.isNotEmpty) {
      // Get BBS public key
      final publicKeyBytes = base58.decode(blsPublicKey.substring(1));

      // Flatten credentialSubject into a list of string values
      final flattenedMessages =
          Tools.flattenMapToListString(vc.credentialSubject ?? {}, '');
      final messages = flattenedMessages.map((s) => utf8.encode(s)).toList();

      // Prepare map to hold selectively disclosed values
      final discloseMap = <String, dynamic>{};

      // Flatten map to get key list for index resolution
      final credentialKeys =
          Tools.flattenMapToMap(vc.credentialSubject ?? {}, '').keys.toList();

      // Collect reveal indexes
      final revealIndex = <int>[];

      for (final fullKey in revealAttribute) {
        if (!credentialKeys.contains(fullKey)) {
          throw ZetrixSDKResult.failure(
              error:
                  DefaultError('Key not found in credentialSubject: $fullKey'));
        }

        revealIndex.add(credentialKeys.indexOf(fullKey));

        final value = Tools.getNestedValue(vc.credentialSubject ?? {}, fullKey);
        Tools.insertNestedValue(discloseMap, fullKey, value);
      }

      final bbs = Bbs();

      // Generate BBS+ proof
      final proof = await bbs.setBbsBlsProofMC(
        messages,
        publicKeyBytes,
        bbsSignature,
        revealIndex,
        bbsVerificationMethod,
      );

      // Update credentialSubject and proof
      vc.credentialSubject = discloseMap;
      vc.proof = [proof];
    }

    final vcList = <VerifiableCredential>[vc];
    vp.verifiableCredential = vcList;
    var vpString = jsonEncode(vp.toJson());
    vpString = Helpers.extractMinimalVp(vpString);
    return ZetrixSDKResult.success(data: vpString);
  }
}
