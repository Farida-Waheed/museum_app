import 'package:flutter/material.dart';
import '../models/exhibit.dart';
import '../core/services/mock_data.dart';

class ExhibitProvider with ChangeNotifier {
  List<Exhibit> _exhibits = [];
  final Set<String> _bookmarkedIds = {};

  ExhibitProvider() {
    _loadExhibits();
  }

  List<Exhibit> get exhibits => _exhibits;
  List<Exhibit> get bookmarkedExhibits => _exhibits.where((e) => _bookmarkedIds.contains(e.id)).toList();

  void _loadExhibits() {
    _exhibits = MockDataService.getAllExhibits();
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }
}
