import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_record.dart';

class HistoryService {
  static const String _keyHistory = 'agrivision_scan_history';
  final SharedPreferences _prefs;

  HistoryService(this._prefs);

  List<ScanRecord> getScanHistory() {
    final list = _prefs.getStringList(_keyHistory);
    if (list == null) return [];
    try {
      return list.map((jsonStr) => ScanRecord.fromJson(jsonStr)).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first
    } catch (_) {
      return [];
    }
  }

  Future<void> saveScanRecord(ScanRecord record) async {
    final history = getScanHistory();
    // Avoid duplicates by ID
    history.removeWhere((r) => r.id == record.id);
    history.insert(0, record);

    final list = history.map((r) => r.toJson()).toList();
    await _prefs.setStringList(_keyHistory, list);
  }

  Future<void> deleteScanRecord(String id) async {
    final history = getScanHistory();
    history.removeWhere((r) => r.id == id);
    final list = history.map((r) => r.toJson()).toList();
    await _prefs.setStringList(_keyHistory, list);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }
}
