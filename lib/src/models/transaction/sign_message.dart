import 'package:json_annotation/json_annotation.dart';

part 'sign_message.g.dart';

@JsonSerializable(explicitToJson: true)
class SignMessage {
  String? signData;
  String? publicKey;

  SignMessage({this.signData, this.publicKey});

  factory SignMessage.fromJson(json) => _$SignMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SignMessageToJson(this);
}
