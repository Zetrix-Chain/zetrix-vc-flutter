import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';
import 'package:zetrix_vc_flutter/src/models/vc/verifiable_credential.dart';

part 'verifiable_presentation.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VerifiablePresentation {
  @JsonKey(name: '@context')
  final List<String>? context;

  final List<String>? type;
  final String? holder;
  List<VerifiableCredential>? verifiableCredential;
  final Proof? proof;

  VerifiablePresentation({
    this.context,
    this.type,
    this.holder,
    this.verifiableCredential,
    this.proof,
  });

  factory VerifiablePresentation.fromJson(Map<String, dynamic> json) =>
      _$VerifiablePresentationFromJson(json);

  Map<String, dynamic> toJson() => _$VerifiablePresentationToJson(this);
}
