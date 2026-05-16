import '../core/constants/pricing.dart';

/// Tour package model for robot guided tours
class TourPackage {
  final String id;
  final String name;
  final String subtitle;
  final int durationMinutes;
  final double price;
  final String currency;
  final List<String> includedFeatures;
  final bool includesMuseumEntry;
  final bool includesRobotTour;
  final bool recommended;

  const TourPackage({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.durationMinutes,
    required this.price,
    required this.currency,
    required this.includedFeatures,
    required this.includesMuseumEntry,
    required this.includesRobotTour,
    this.recommended = false,
  });

  /// Create a copy with optional field overrides
  TourPackage copyWith({
    String? id,
    String? name,
    String? subtitle,
    int? durationMinutes,
    double? price,
    String? currency,
    List<String>? includedFeatures,
    bool? includesMuseumEntry,
    bool? includesRobotTour,
    bool? recommended,
  }) {
    return TourPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      includedFeatures: includedFeatures ?? this.includedFeatures,
      includesMuseumEntry: includesMuseumEntry ?? this.includesMuseumEntry,
      includesRobotTour: includesRobotTour ?? this.includesRobotTour,
      recommended: recommended ?? this.recommended,
    );
  }

  /// Mock packages for development
  static List<TourPackage> get mockPackages => [
    // Museum Entry Only
    const TourPackage(
      id: 'museum-entry-only',
      name: 'Museum Entry Only',
      subtitle: 'Access to museum exhibits',
      durationMinutes: 0, // Not applicable
      price: BookingPricing.egyptianAdult,
      currency: BookingPricing.currency,
      includedFeatures: [
        'Museum entry access',
        'Exhibit exploration',
        'Audio guide access',
      ],
      includesMuseumEntry: true,
      includesRobotTour: false,
      recommended: false,
    ),

    // Robot Tour Only
    const TourPackage(
      id: 'robot-tour-only',
      name: 'Horus-Bot Guided Tour',
      subtitle: 'Interactive robot-guided experience',
      durationMinutes: 45,
      price: BookingPricing.standardRobotTour,
      currency: BookingPricing.currency,
      includedFeatures: [
        'Personal robot guide',
        'Interactive storytelling',
        'Photo opportunities',
        'Live navigation',
        'Expert explanations',
      ],
      includesMuseumEntry: false,
      includesRobotTour: true,
      recommended: false,
    ),

    // Complete Experience Bundle
    const TourPackage(
      id: 'complete-bundle',
      name: 'Complete Experience Bundle',
      subtitle: 'Museum entry + robot guided tour',
      durationMinutes: 45,
      price: BookingPricing.egyptianAdult + BookingPricing.standardRobotTour,
      currency: BookingPricing.currency,
      includedFeatures: [
        'Museum entry access',
        'Exhibit exploration',
        'Personal robot guide',
        'Interactive storytelling',
        'Photo opportunities',
        'Live navigation',
        'Expert explanations',
      ],
      includesMuseumEntry: true,
      includesRobotTour: true,
      recommended: true,
    ),
  ];
}
