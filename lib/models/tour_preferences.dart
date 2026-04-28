import 'package:uuid/uuid.dart';

class TourPreferences {
  final String id;
  final List<String> selectedExhibitIds;
  final int durationMinutes;
  final DateTime createdAt;

  TourPreferences({
    String? id,
    required this.selectedExhibitIds,
    required this.durationMinutes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  TourPreferences copyWith({
    List<String>? selectedExhibitIds,
    int? durationMinutes,
  }) {
    return TourPreferences(
      id: id,
      selectedExhibitIds: selectedExhibitIds ?? this.selectedExhibitIds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selectedExhibitIds': selectedExhibitIds,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TourPreferences.fromJson(Map<String, dynamic> json) {
    return TourPreferences(
      id: json['id'] as String,
      selectedExhibitIds: List<String>.from(json['selectedExhibitIds'] as List),
      durationMinutes: json['durationMinutes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
