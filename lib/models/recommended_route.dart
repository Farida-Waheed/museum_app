class RecommendedRoute {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final String theme;
  final List<String> recommendedFor;
  final int durationMin;
  final String pace;
  final bool kidsFriendly;
  final bool photoSpots;
  final String coverImage;
  final List<String> artifactIds;
  final String recommendedLanguage;
  final bool isActive;
  final int routeOrder;

  const RecommendedRoute({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.theme,
    required this.recommendedFor,
    required this.durationMin,
    required this.pace,
    required this.kidsFriendly,
    required this.photoSpots,
    required this.coverImage,
    required this.artifactIds,
    required this.recommendedLanguage,
    required this.isActive,
    required this.routeOrder,
  });

  factory RecommendedRoute.fromJson(Map<String, dynamic> json) {
    return RecommendedRoute(
      id: _stringValue(json['id']),
      titleEn: _stringValue(json['title_en']),
      titleAr: _stringValue(json['title_ar']),
      descriptionEn: _stringValue(json['description_en']),
      descriptionAr: _stringValue(json['description_ar']),
      theme: _stringValue(json['theme']),
      recommendedFor: _stringList(json['recommended_for']),
      durationMin: _intValue(json['duration_min']),
      pace: _stringValue(json['pace']),
      kidsFriendly: json['kids_friendly'] == true,
      photoSpots: json['photo_spots'] == true,
      coverImage: _stringValue(json['cover_image']),
      artifactIds: _stringList(json['artifact_ids']),
      recommendedLanguage: _stringValue(json['recommended_language']),
      isActive: json['is_active'] == true,
      routeOrder: _intValue(json['route_order']),
    );
  }

  String title(String languageCode) => languageCode == 'ar' ? titleAr : titleEn;

  String description(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  bool get hasMobileCoverAsset => coverImage.startsWith('assets/');

  static String _stringValue(Object? value) {
    return value is String ? value : '';
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }
}

class RecommendedRouteLoadResult {
  final List<RecommendedRoute> routes;
  final List<String> warnings;

  const RecommendedRouteLoadResult({
    required this.routes,
    required this.warnings,
  });

  bool get isValid => warnings.isEmpty;
}
