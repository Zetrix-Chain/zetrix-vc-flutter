import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'sdk_exceptions.dart';

part 'sdk_result.freezed.dart';

@freezed
abstract class ZetrixSDKResult<T> with _$ZetrixSDKResult<T> {
  const factory ZetrixSDKResult.success({T? data}) = Success<T>;

  const factory ZetrixSDKResult.failure({ZetrixSDKExceptions? error}) =
      Failure<T>;
}
