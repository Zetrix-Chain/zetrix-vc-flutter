import 'package:json_annotation/json_annotation.dart';

part 'account_valid.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountValid extends JsonSerializable {
  bool? isValid;

  AccountValid({this.isValid});

  factory AccountValid.fromJson(Map<String, dynamic> json) =>
      _$AccountValidFromJson(json);

  Map<String, dynamic> toJson() => _$AccountValidToJson(this);
}
