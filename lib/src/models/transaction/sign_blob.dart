import 'package:json_annotation/json_annotation.dart';

part 'sign_blob.g.dart';

@JsonSerializable(explicitToJson: true)
class SignBlob {
  String? signBlob;
  String? publicKey;

  SignBlob({this.signBlob, this.publicKey});

  factory SignBlob.fromJson(json) => _$SignBlobFromJson(json);

  Map<String, dynamic> toJson() => _$SignBlobToJson(this);
}
