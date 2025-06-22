// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:freezed_annotation/freezed_annotation.dart';

part 'proof.g.dart';

@JsonSerializable()
class Proof {
  String? type;
  String? created;
  String? proofPurpose;
  String? proofValue;
  String? verificationMethod;
  String? jws;
  String? nonce;

  Proof(
      {this.type,
      this.created,
      this.proofPurpose,
      this.proofValue,
      this.verificationMethod,
      this.jws,
      this.nonce});

  factory Proof.fromJson(Map<String, dynamic> json) => _$ProofFromJson(json);

  Map<String, dynamic> toJson() => _$ProofToJson(this);
}
