import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'sdk_exceptions.dart';

part 'sdk_result.freezed.dart';

/// A sealed class that represents the result of an operation in the Zetrix SDK,
/// leveraging the `freezed` package to handle two possible outcomes: success or failure.
///
/// This class is generic and can handle any type of data (`T`) in the case of success,
/// or an error represented by `ZetrixSDKExceptions` in the case of failure.
///
/// **Key Features:**
/// - Provides a standardized way to represent the result of an operation.
/// - Offers two states: [Success] and [Failure].
/// - [Success] encapsulates the result data (if the operation succeeds).
/// - [Failure] encapsulates an exception or error (if the operation fails).
///
/// **Usage Example:**
/// ```dart
/// ZetrixSDKResult<String> result = ZetrixSDKResult.success(data: "Operation succeeded");
///
/// result.when(
///   success: (data) {
///     print("Success: $data");
///   },
///   failure: (error) {
///     print("Failure: ${error?.message}");
///   },
/// );
/// ```
@freezed
abstract class ZetrixSDKResult<T> with _$ZetrixSDKResult<T> {
  /// Represents a successful operation, containing the result data.
  ///
  /// **Parameters:**
  /// - [data]: The result data (`T?`) from the operation. This can be `null` if no data is returned.
  const factory ZetrixSDKResult.success({T? data}) = Success<T>;

  /// Represents a failed operation, containing the error or exception details.
  ///
  /// **Parameters:**
  /// - [error]: An instance of [ZetrixSDKExceptions] that provides details about the failure.
  const factory ZetrixSDKResult.failure({ZetrixSDKExceptions? error}) =
      Failure<T>;
}
