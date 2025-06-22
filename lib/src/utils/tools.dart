import 'package:logger/logger.dart';

/// Utility class that provides helper methods for common operations,
/// such as string validation, map manipulation, and list handling.
///
/// The `Tools` class contains static methods for operations that don't
/// require instance-level state.
class Tools {
  /// Checks whether the given [str] is null or an empty string.
  ///
  /// Returns `true` if the string is null or empty, otherwise returns `false`.
  static bool isEmptyString(String? str) {
    return str == null || str.isEmpty;
  }

  /// Checks whether the given object [obj] is null or an empty string.
  ///
  /// Returns `true` for `null` or empty string values, otherwise returns `false`.
  static bool isEmptyObject(Object? obj) {
    return obj == null || obj == "";
  }

  /// Checks whether the given list [obj] is null or has no elements.
  ///
  /// Returns `true` if the list is null or empty, otherwise returns `false`.
  static bool isEmptyList(List<Object>? obj) {
    return obj == null || obj.isEmpty;
  }

  /// Validates whether the provided [gas] value is a non-empty string and
  /// falls within a valid range as defined by the pattern.
  ///
  /// The [gas] must match the regex pattern and range between 0 and
  /// [double.maxFinite]. Returns `true` if the value is valid, otherwise `false`.
  static bool isAvailableZTX(String gas) {
    if (isEmptyString(gas)) {
      return false;
    }
    final regex = RegExp(r"^(([1-9]\d*)+|0)(\.\d{1,8})?$");
    return (regex.hasMatch(gas) &&
        double.parse(gas) >= 0 &&
        double.parse(gas) <= double.maxFinite);
  }

  /// Validates whether the provided [ugas] value is a non-empty string and
  /// falls within a specific numeric range.
  ///
  /// Returns `true` if the [ugas] value is valid, otherwise `false`.
  static bool isAvailableValue(String ugas) {
    if (isEmptyString(ugas)) {
      return false;
    }
    final regex = RegExp(r"^(0|([1-9]\d*))$");
    return (regex.hasMatch(ugas) &&
        double.parse(ugas) > -1 &&
        double.parse(ugas) <= double.maxFinite);
  }

  /// Checks whether all key-value pairs in a [params] map have non-null values.
  ///
  /// Returns `true` if all values are non-null, otherwise `false`.
  static bool validateParams(Map<String, dynamic> params) {
    bool validated = true;

    params.forEach((k, v) {
      if (v == null) {
        validated = false;
      }
    });

    return validated;
  }

  /// Flattens a nested [map] into a flat map where keys are represented
  /// as dot-separated strings.
  ///
  /// [prefix] is used for nesting and is optional. This method converts
  /// hierarchical structures into flat key-value pairs.
  Map<String, dynamic> flatten(Map<String, dynamic> map, [String prefix = '']) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(flatten(value, newKey));
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }

  /// Recursively flattens a nested [map] into a **list** of key-value strings.
  ///
  /// Keys in the map are concatenated with dot notation to represent nesting.
  static List<String> flattenMapToListString(Map<String, dynamic> map,
      [String prefix = '']) {
    final List<String> result = [];

    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        result.addAll(flattenMapToListString(value, fullKey));
      } else {
        result.add('$fullKey: $value');
      }
    });

    return result;
  }

  /// Recursively flattens a nested [map] into a **map** with dot-notated keys.
  ///
  /// Converts nested maps into single-level maps with keys denoting the
  /// hierarchy using dot notation.
  static Map<String, dynamic> flattenMapToMap(Map<String, dynamic> map,
      [String prefix = '']) {
    final Map<String, dynamic> result = {};

    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        result.addAll(flattenMapToMap(value, fullKey));
      } else {
        result[fullKey] = value;
      }
    });

    return result;
  }

  /// Inserts a [value] into a nested [map] using a dot-separated [keyPath].
  ///
  /// If intermediate maps in the key path do not exist, they are created.
  static void insertNestedValue(
      Map<String, dynamic> map, String keyPath, dynamic value) {
    final keys = keyPath.split('.');
    Map<String, dynamic> current = map;

    for (int i = 0; i < keys.length - 1; i++) {
      final k = keys[i];
      current = current.putIfAbsent(k, () => <String, dynamic>{})
          as Map<String, dynamic>;
    }

    current[keys.last] = value;
  }

  /// Retrieves a value from a nested [map] using a dot-separated [keyPath].
  ///
  /// Returns the desired value if it exists, or `null` if the key path
  /// cannot be resolved.
  static dynamic getNestedValue(Map<String, dynamic> map, String keyPath) {
    final keys = keyPath.split('.');
    dynamic value = map;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }

    return value;
  }

  /// Logs a debug message using the PrettyPrinter format.
  ///
  /// This method initializes a logger with a [PrettyPrinter] and logs the provided message
  /// at the debug (`d`) level. It is primarily used for structured and readable debugging output.
  static void logDebug(dynamic msg) {
    var logger = Logger(
      printer: PrettyPrinter(),
    );
    logger.d(msg);
  }
}
