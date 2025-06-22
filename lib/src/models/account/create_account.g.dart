// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAccount _$CreateAccountFromJson(Map<String, dynamic> json) =>
    CreateAccount(
      privateKey: json['privateKey'] as String?,
      publicKey: json['publicKey'] as String?,
      address: json['address'] as String?,
      did: json['did'] as String?,
    );

Map<String, dynamic> _$CreateAccountToJson(CreateAccount instance) =>
    <String, dynamic>{
      'privateKey': instance.privateKey,
      'publicKey': instance.publicKey,
      'address': instance.address,
      'did': instance.did,
    };
