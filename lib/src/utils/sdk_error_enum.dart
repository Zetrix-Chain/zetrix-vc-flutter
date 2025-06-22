enum SdkError {
  success(0, "Success"),
  accessTokenInvalid(2, "Access token invalid"),
  queryResultNotExist(4, "Query result not exist"),
  invalidParameter(999, "Invalid Parameter"),
  tokenNotExist(1000, "Token does not exist"),
  resultNotFound(1002, "Result not found");

  final int code;
  final String description;

  const SdkError(this.code, this.description);

  @override
  String toString() => 'ErrorCode: $code, ErrorDesc: $description)';
}
