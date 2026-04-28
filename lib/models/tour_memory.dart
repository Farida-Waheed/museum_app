import 'package:uuid/uuid.dart';

class TourMemory {
  final String id;
  final String exhibitId;
  final String exhibitName;
  final String? note;
  final String? imagePath;
  final DateTime timestamp;

  TourMemory({
    String? id,
    required this.exhibitId,
    required this.exhibitName,
    this.note,
    this.imagePath,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  TourMemory copyWith({String? note, String? imagePath}) {
    return TourMemory(
      id: id,
      exhibitId: exhibitId,
      exhibitName: exhibitName,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exhibitId': exhibitId,
      'exhibitName': exhibitName,
      'note': note,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TourMemory.fromJson(Map<String, dynamic> json) {
    return TourMemory(
      id: json['id'] as String,
      exhibitId: json['exhibitId'] as String,
      exhibitName: json['exhibitName'] as String,
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
