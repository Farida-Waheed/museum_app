import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exhibit.dart';
import '../models/recommended_route.dart';

class RecommendedRoutesService {
  static const String assetPath =
      'shared/booking-product-system/recommended_routes.v1.json';
  static final RegExp _artifactIdPattern = RegExp(r'^artifact_\d{3}$');

  Future<RecommendedRouteLoadResult> load({
    required Iterable<Exhibit> exhibits,
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const RecommendedRouteLoadResult(
          routes: [],
          warnings: ['Recommended routes JSON root is not a list.'],
        );
      }

      final routes =
          decoded
              .whereType<Map<String, dynamic>>()
              .map(RecommendedRoute.fromJson)
              .toList()
            ..sort((a, b) => a.routeOrder.compareTo(b.routeOrder));
      final warnings = validate(routes: routes, exhibits: exhibits);

      return RecommendedRouteLoadResult(routes: routes, warnings: warnings);
    } catch (error) {
      return RecommendedRouteLoadResult(
        routes: const [],
        warnings: ['Unable to load recommended routes: $error'],
      );
    }
  }

  List<String> validate({
    required List<RecommendedRoute> routes,
    required Iterable<Exhibit> exhibits,
  }) {
    final warnings = <String>[];
    final exhibitIds = exhibits.map((exhibit) => exhibit.id).toSet();
    final routeIds = <String>{};

    if (routes.length != 7) {
      warnings.add('Expected 7 recommended routes, found ${routes.length}.');
    }

    for (final route in routes) {
      if (route.id.trim().isEmpty) {
        warnings.add('Recommended route has an empty id.');
      } else if (!routeIds.add(route.id)) {
        warnings.add('Duplicate recommended route id: ${route.id}.');
      }

      if (route.titleEn.trim().isEmpty || route.titleAr.trim().isEmpty) {
        warnings.add('${route.id}: missing title content.');
      }
      if (route.descriptionEn.trim().isEmpty ||
          route.descriptionAr.trim().isEmpty) {
        warnings.add('${route.id}: missing description content.');
      }

      final artifactIds = <String>{};
      for (final artifactId in route.artifactIds) {
        if (!_artifactIdPattern.hasMatch(artifactId)) {
          warnings.add('${route.id}: invalid artifact id $artifactId.');
          continue;
        }
        if (!artifactIds.add(artifactId)) {
          warnings.add('${route.id}: duplicate artifact id $artifactId.');
        }
        if (!exhibitIds.contains(artifactId)) {
          warnings.add('${route.id}: unknown artifact id $artifactId.');
        }
      }
    }

    return warnings;
  }
}
