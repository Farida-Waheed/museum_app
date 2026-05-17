import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exhibit.dart';
import '../core/services/exhibit_fallback_data.dart';

class ExhibitProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  List<Exhibit> _exhibits = [];
  final Set<String> _bookmarkedIds = {};
  bool _isLoading = true;
  String? _error;

  ExhibitProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _loadExhibits();
  }

  List<Exhibit> get exhibits => _exhibits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Exhibit> get bookmarkedExhibits =>
      _exhibits.where((e) => _bookmarkedIds.contains(e.id)).toList();

  Future<void> _loadExhibits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('exhibits')
          .where('is_active', isEqualTo: true)
          .get();
      final firestoreExhibits =
          snapshot.docs
              .map((doc) => Exhibit.fromFirestore(doc.id, doc.data()))
              .where((exhibit) => exhibit.nameEn.isNotEmpty)
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      _exhibits = firestoreExhibits.isEmpty
          ? await _loadFallbackExhibits()
          : firestoreExhibits;
    } on FirebaseException catch (e) {
      _error = e.code == 'permission-denied'
          ? 'Firestore rules blocked exhibit access.'
          : 'Unable to load exhibits.';
      _exhibits = await _loadFallbackExhibits();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Exhibit>> _loadFallbackExhibits() async {
    try {
      return await ExhibitFallbackData.load();
    } catch (_) {
      _error ??= 'Unable to load exhibit fallback data.';
      return const [];
    }
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
