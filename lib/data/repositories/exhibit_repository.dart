import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/exhibit.dart';

class ExhibitRepository {
  Future<Map<String, dynamic>> loadExhibitData(String exhibitId) async {
    try {
      final String response = await rootBundle.loadString('assets/data/museums/gem/exhibits/$exhibitId.json');
      return json.decode(response);
    } catch (e) {
      print('Error loading exhibit data: $e');
      return {};
    }
  }
}
