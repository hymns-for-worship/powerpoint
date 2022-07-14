import 'dart:convert';

extension MapUtils on Map<String, dynamic> {
  Map<String, dynamic> clone() {
    final data = jsonDecode(jsonEncode(this));
    return data as Map<String, dynamic>;
  }
}
