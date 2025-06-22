import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';

part 'verifiable_credential.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VerifiableCredential {
  @JsonKey(name: '@context')
  final List<String>? context;

  final String? id;
  final List<String>? type;
  final String? issuer;
  final String? issuanceDate;
  final String? expirationDate;
  Map<String, dynamic>? credentialSubject;
  List<Proof>? proof;

  VerifiableCredential({
    this.context,
    this.id,
    this.type,
    this.issuer,
    this.issuanceDate,
    this.expirationDate,
    this.credentialSubject,
    this.proof,
  });

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) =>
      _$VerifiableCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$VerifiableCredentialToJson(this);
}
