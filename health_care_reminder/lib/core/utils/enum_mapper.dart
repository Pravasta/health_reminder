// Author: Pravasta Rama - 2026

import 'dart:convert';

String enumToDb(Enum e) => e.name;

int enumToDbInt(Enum e) => e.index;

T enumFromDb<T extends Enum>(List<T> values, String dbValue) {
  return values.firstWhere(
    (e) => e.name == dbValue,
    orElse: () => throw ArgumentError('No enum value found for $dbValue'),
  );
}

T enumFromDbInt<T extends Enum>(List<T> values, int dbValue) {
  return values.firstWhere(
    (e) => e.index == dbValue,
    orElse: () => throw ArgumentError('No enum value found for index $dbValue'),
  );
}

List<String> decodeList(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    return List<String>.from(jsonDecode(value));
  }
  if (value is List) {
    return List<String>.from(value);
  }
  return [];
}

String encodeList(List<String> list) {
  return jsonEncode(list);
}
