import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_account.g.dart';

/// Represents the details required to create and manage a blockchain account.
///
/// The `CreateAccount` class encapsulates key information for a user account, such as the
/// public and private keys, blockchain address, and decentralized identifier (DID).
/// It supports JSON serialization and deserialization for external data exchange, such
/// as interacting with APIs or storing user account data.

@JsonSerializable(explicitToJson: true)
class CreateAccount {
  /// Private key of the account, used for signing and decrypting data.
  @JsonKey(name: "privateKey")
  String? privateKey;

  /// Public key of the account, used for verifying signatures and encrypting data.
  @JsonKey(name: "publicKey")
  String? publicKey;

  /// Blockchain address of the account, typically derived from the public key.
  @JsonKey(name: "address")
  String? address;

  /// Decentralized Identifier (DID) for the account, used in decentralized identity systems.
  @JsonKey(name: "did")
  String? did;

  /// Constructs a `CreateAccount` instance with the optional fields [privateKey],
  /// [publicKey], [address], and [did].
  CreateAccount({
    this.privateKey,
    this.publicKey,
    this.address,
    this.did,
  });

  /// Factory constructor for creating a `CreateAccount` instance from a JSON object.
  factory CreateAccount.fromJson(Map<String, dynamic> json) =>
      _$CreateAccountFromJson(json);

  /// Converts the `CreateAccount` instance into a JSON object for serialization.
  Map<String, dynamic> toJson() => _$CreateAccountToJson(this);

  /// Static function for creating an instance from a raw JSON model.
  static CreateAccount fromJsonModel(Map<String, dynamic> json) =>
      CreateAccount.fromJson(json);
}
