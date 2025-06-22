// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_blob.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignBlob _$SignBlobFromJson(Map<String, dynamic> json) => SignBlob(
      signBlob: json['signBlob'] as String?,
      publicKey: json['publicKey'] as String?,
    );

Map<String, dynamic> _$SignBlobToJson(SignBlob instance) => <String, dynamic>{
      'signBlob': instance.signBlob,
      'publicKey': instance.publicKey,
    };
