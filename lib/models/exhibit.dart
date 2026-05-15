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
  final int? routeOrder;
  final List<String> themes;
  final List<String> tags;
  final bool photoSpot;
  final int? recommendedDurationMin;
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
    this.routeOrder,
    this.themes = const [],
    this.tags = const [],
    this.photoSpot = false,
    this.recommendedDurationMin,
    required this.x,
    required this.y,
  });

  factory Exhibit.fromFirestore(String docId, Map<String, dynamic> data) {
    final locations = data['locations'];
    final media = data['media'];
    final contentEn = data['content_en'];
    final contentAr = data['content_ar'];
    final location = data['location'] ?? (locations is Map ? locations['map'] : null);
    final x = location is GeoPoint
        ? location.longitude
        : _doubleValue(location is Map ? location['x'] : data['x']) ?? 0;
    final y = location is GeoPoint
        ? location.latitude
        : _doubleValue(location is Map ? location['y'] : data['y']) ?? 0;
    final titleEn =
        _stringValue(data['title_en']) ??
        _stringValue(data['nameEn']) ??
        _stringValue(data['name']) ??
        '';
    final descriptionEn =
        _stringValue(contentEn is Map ? contentEn['summary'] : null) ??
        _stringValue(contentEn is Map ? contentEn['historical_background'] : null) ??
        _stringValue(data['descriptionEn']) ??
        '';
    final titleAr =
        _stringValue(data['title_ar']) ??
        _stringValue(data['nameAr']) ??
        titleEn;
    final descriptionAr =
        _stringValue(contentAr is Map ? contentAr['summary'] : null) ??
        _stringValue(data['descriptionAr']) ??
        descriptionEn;

    return Exhibit(
      id: _stringValue(data['id']) ?? _stringValue(data['exhibitId']) ?? docId,
      nameEn: titleEn,
      nameAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      imageAsset:
          _stringValue(media is Map ? media['image_asset'] : null) ??
          _stringValue(data['imageAsset']) ??
          'assets/images/museum_interior.jpg',
      imageUrl:
          _stringValue(media is Map ? media['image_url'] : null) ??
          _stringValue(data['imageUrl']) ??
          '',
      audioUrl: _stringValue(data['audioUrl']),
      category: _stringValue(data['historical_period']) ??
          _stringValue(data['category']) ??
          '',
      floor:
          _stringValue(locations is Map ? locations['floor'] : null) ??
          _stringValue(data['floor']) ??
          '',
      isActive:
          (data['is_active'] is bool ? data['is_active'] as bool : null) ??
          (data['isActive'] is bool ? data['isActive'] as bool : true),
      routeOrder: _intValue(data['route_order']),
      themes: _stringList(data['themes']),
      tags: _stringList(data['tags']),
      photoSpot: data['photo_spot'] is bool ? data['photo_spot'] as bool : false,
      recommendedDurationMin: _intValue(data['recommended_duration_min']),
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

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }
}
