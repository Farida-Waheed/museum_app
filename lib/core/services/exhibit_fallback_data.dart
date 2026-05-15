import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/exhibit.dart';

class ExhibitFallbackData {
  static const String assetPath =
      'shared/booking-product-system/exhibits.v1.json';

  static Future<List<Exhibit>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    final exhibitsJson = decoded is Map<String, dynamic>
        ? decoded['exhibits']
        : decoded;
    if (exhibitsJson is! List) return const [];

    final exhibits = exhibitsJson
        .whereType<Map<String, dynamic>>()
        .map((json) => Exhibit.fromFirestore(json['id'] as String? ?? '', json))
        .where((exhibit) => exhibit.id.startsWith('artifact_'))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return exhibits;
  }
}
