class RobotSyncModel {
  final String tourId;
  final String status;
  final String currentExhibitId;
  final String? nextExhibitId;
  final int progressIndex;
  final int totalStops;
  final int etaSeconds;
  final DateTime updatedAt;

  RobotSyncModel({
    required this.tourId,
    required this.status,
    required this.currentExhibitId,
    this.nextExhibitId,
    required this.progressIndex,
    required this.totalStops,
    required this.etaSeconds,
    required this.updatedAt,
  });

  factory RobotSyncModel.fromJson(Map<String, dynamic> json) {
    return RobotSyncModel(
      tourId: json['tour_id'],
      status: json['status'],
      currentExhibitId: json['current_exhibit_id'],
      nextExhibitId: json['next_exhibit_id'],
      progressIndex: json['progress_index'],
      totalStops: json['total_stops'],
      etaSeconds: json['eta_seconds'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
