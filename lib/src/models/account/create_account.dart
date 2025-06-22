import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_account.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateAccount {
  @JsonKey(name: "privateKey")
  String? privateKey;

  @JsonKey(name: "publicKey")
  String? publicKey;

  @JsonKey(name: "address")
  String? address;

  @JsonKey(name: "did")
  String? did;

  CreateAccount({this.privateKey, this.publicKey, this.address, this.did});

  factory CreateAccount.fromJson(Map<String, dynamic> json) =>
      _$CreateAccountFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAccountToJson(this);

  static CreateAccount fromJsonModel(Map<String, dynamic> json) =>
      CreateAccount.fromJson(json);
}
