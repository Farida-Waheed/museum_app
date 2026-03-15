import 'package:flutter/material.dart';

class Exhibit {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String imageAsset;
  final double x; // Map X coordinate
  final double y; // Map Y coordinate

  Exhibit({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.imageAsset,
    required this.x,
    required this.y,
  });

  // Helper to get text based on current language
  String getName(String langCode) => langCode == 'ar' ? nameAr : nameEn;
  String getDescription(String langCode) => langCode == 'ar' ? descriptionAr : descriptionEn;
  
  // Helper to get Offset for the Map
  Offset get position => Offset(x, y);
}