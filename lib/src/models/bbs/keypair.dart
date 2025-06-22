// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zetrix_vc_flutter/converters/uint8list_converter.dart';

part 'keypair.g.dart';

@JsonSerializable()
@Uint8ListBase64Converter()
class KeyPair {
  final Uint8List? secretKey, publicKey;

  KeyPair({required this.secretKey, required this.publicKey});

  factory KeyPair.fromJson(Map<String, dynamic> json) =>
      _$KeyPairFromJson(json);

  Map<String, dynamic> toJson() => _$KeyPairToJson(this);
}
