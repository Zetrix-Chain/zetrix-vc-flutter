// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignMessage _$SignMessageFromJson(Map<String, dynamic> json) => SignMessage(
      signData: json['signData'] as String?,
      publicKey: json['publicKey'] as String?,
    );

Map<String, dynamic> _$SignMessageToJson(SignMessage instance) =>
    <String, dynamic>{
      'signData': instance.signData,
      'publicKey': instance.publicKey,
    };
