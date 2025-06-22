// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keypair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyPair _$KeyPairFromJson(Map<String, dynamic> json) => KeyPair(
      secretKey: const Uint8ListBase64Converter()
          .fromJson(json['secretKey'] as String?),
      publicKey: const Uint8ListBase64Converter()
          .fromJson(json['publicKey'] as String?),
    );

Map<String, dynamic> _$KeyPairToJson(KeyPair instance) => <String, dynamic>{
      'secretKey': const Uint8ListBase64Converter().toJson(instance.secretKey),
      'publicKey': const Uint8ListBase64Converter().toJson(instance.publicKey),
    };
