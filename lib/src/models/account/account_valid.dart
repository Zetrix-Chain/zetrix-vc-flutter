import 'package:json_annotation/json_annotation.dart';

part 'account_valid.g.dart';

/// Represents the validation status of an account.
///
/// The `AccountValid` class is a simple data model designed to store whether an account
/// is valid or not. It is primarily used for account validation checks and supports
/// JSON serialization and deserialization.
@JsonSerializable(explicitToJson: true)
class AccountValid extends JsonSerializable {
  /// Represents the validation status of the account.
  /// - `true`: The account is valid.
  /// - `false`: The account is invalid.
  /// - `null`: The validation status is unknown or unspecified.
  bool? isValid;

  /// Constructs an `AccountValid` instance with an optional [isValid] field.
  ///
  /// ### Parameters:
  /// - [isValid]: A `bool` that represents the account validation status.
  AccountValid({this.isValid});

  /// Factory constructor for creating an `AccountValid` instance from a JSON object.
  factory AccountValid.fromJson(Map<String, dynamic> json) =>
      _$AccountValidFromJson(json);

  /// Converts the `AccountValid` instance into a JSON object for serialization.
  @override
  Map<String, dynamic> toJson() => _$AccountValidToJson(this);
}
