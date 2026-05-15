import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Exhibit {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String imageAsset;
  final String imageUrl;
  final String? audioUrl;
  final String category;
  final String floor;
  final bool isActive;
  final double x; // Map X coordinate
  final double y; // Map Y coordinate

  Exhibit({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.imageAsset,
    this.imageUrl = '',
    this.audioUrl,
    this.category = '',
    this.floor = '',
    this.isActive = true,
    required this.x,
    required this.y,
  });

  factory Exhibit.fromFirestore(String docId, Map<String, dynamic> data) {
    final location = data['location'];
    final x = location is GeoPoint
        ? location.longitude
        : _doubleValue(location is Map ? location['x'] : data['x']) ?? 0;
    final y = location is GeoPoint
        ? location.latitude
        : _doubleValue(location is Map ? location['y'] : data['y']) ?? 0;

    return Exhibit(
      id: _stringValue(data['exhibitId']) ?? docId,
      nameEn: _stringValue(data['nameEn']) ?? _stringValue(data['name']) ?? '',
      nameAr:
          _stringValue(data['nameAr']) ?? _stringValue(data['nameEn']) ?? '',
      descriptionEn: _stringValue(data['descriptionEn']) ?? '',
      descriptionAr:
          _stringValue(data['descriptionAr']) ??
          _stringValue(data['descriptionEn']) ??
          '',
      imageAsset:
          _stringValue(data['imageAsset']) ??
          'assets/images/museum_interior.jpg',
      imageUrl: _stringValue(data['imageUrl']) ?? '',
      audioUrl: _stringValue(data['audioUrl']),
      category: _stringValue(data['category']) ?? '',
      floor: _stringValue(data['floor']) ?? '',
      isActive: data['isActive'] is bool ? data['isActive'] as bool : true,
      x: x,
      y: y,
    );
  }

  // Helper to get text based on current language
  String getName(String langCode) => langCode == 'ar' ? nameAr : nameEn;
  String getDescription(String langCode) =>
      langCode == 'ar' ? descriptionAr : descriptionEn;

  // Helper to get Offset for the Map
  Offset get position => Offset(x, y);

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static double? _doubleValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
