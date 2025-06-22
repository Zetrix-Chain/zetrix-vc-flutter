/// Enum representing various SDK errors and their associated details.
enum SdkError {
  /// Indicates that the operation was successful.
  success(0, "Success"),

  /// Indicates that the provided access token is invalid.
  accessTokenInvalid(2, "Access token invalid"),

  /// Indicates that the requested query result does not exist.
  queryResultNotExist(4, "Query result not exist"),

  /// Indicates that an invalid parameter was supplied to the operation.
  invalidParameter(999, "Invalid Parameter"),

  /// Indicates that the specified token does not exist.
  tokenNotExist(1000, "Token does not exist"),

  /// Indicates that a requested result could not be found.
  resultNotFound(1002, "Result not found");

  /// The unique error code associated with the SDK error.
  final int code;

  /// The description providing additional details about the SDK error.
  final String description;

  /// Constructs an `SdkError` instance with a specific [code] and [description].
  const SdkError(this.code, this.description);

  /// Converts the SDK error into a readable string format.
  ///
  /// Returns a string containing the error code and description in the format:
  /// `ErrorCode: <code>, ErrorDesc: <description>`.
  @override
  String toString() => 'ErrorCode: $code, ErrorDesc: $description)';
}
