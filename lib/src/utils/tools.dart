class Tools {
  static bool isEmptyString(String? str) {
    return str == null || str.isEmpty;
  }

  static bool isEmptyObject(Object? obj) {
    return obj == null || obj == "";
  }

  static bool isEmptyList(List<Object>? obj) {
    return obj == null || obj.isEmpty;
  }

  static bool isAvailableZTX(String gas) {
    if (isEmptyString(gas)) {
      return false;
    }
    final regex = RegExp(r"^(([1-9]\d*)+|0)(\.\d{1,8})?$");
    return (regex.hasMatch(gas) &&
        double.parse(gas) >= 0 &&
        double.parse(gas) <= double.maxFinite);
  }

  static bool isAvailableValue(String ugas) {
    if (isEmptyString(ugas)) {
      return false;
    }
    final regex = RegExp(r"^(0|([1-9]\d*))$");
    return (regex.hasMatch(ugas) &&
        double.parse(ugas) > -1 &&
        double.parse(ugas) <= double.maxFinite);
  }

  static bool validateParams(Map<String, dynamic> params) {
    bool validated = true;

    params.forEach((k, v) {
      if (v == null) {
        validated = false;
      }
    });

    return validated;
  }

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

  //Recursively flattens a nested map into a list of key-value strings.
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

  // Recursively flattens a nested Map into a flat Map with dot-notated keys.
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

  //Inserts a value into a nested map using a dot-separated key.
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

  //Retrieves a value from a nested map using a dot-separated key.
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
}
