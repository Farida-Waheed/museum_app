import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static const _kTours = 'progress_tours';
  static const _kQuizzes = 'progress_quizzes';
  static const _kExhibits = 'progress_exhibits';
  static const _kLastPlan = 'progress_last_plan';

  static Future<Map<String, int>> getStats() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'tours': sp.getInt(_kTours) ?? 0,
      'quizzes': sp.getInt(_kQuizzes) ?? 0,
      'exhibits': sp.getInt(_kExhibits) ?? 0,
    };
  }

  static Future<String?> getLastPlan() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLastPlan);
  }

  static Future<void> setLastPlan(String summary) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastPlan, summary);
  }

  static Future<void> resetAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kTours, 0);
    await sp.setInt(_kQuizzes, 0);
    await sp.setInt(_kExhibits, 0);
    await sp.remove(_kLastPlan);
  }

  static Future<void> increment(String key, {int by = 1}) async {
    final sp = await SharedPreferences.getInstance();
    final storageKey = _mapKey(key);
    final current = sp.getInt(storageKey) ?? 0;
    await sp.setInt(storageKey, current + by);
  }

  static String _mapKey(String key) {
    switch (key) {
      case 'tours':
        return _kTours;
      case 'quizzes':
        return _kQuizzes;
      case 'exhibits':
        return _kExhibits;
      default:
        return _kTours;
    }
  }
}
