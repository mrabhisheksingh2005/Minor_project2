import 'package:flutter/material.dart';
import '../../../core/models/scan_record.dart';
import '../../../core/services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _historyService;
  List<ScanRecord> _scanHistory = [];
  bool _isLoading = false;

  HistoryProvider(this._historyService) {
    loadHistory();
  }

  List<ScanRecord> get scanHistory => _scanHistory;
  bool get isLoading => _isLoading;

  void loadHistory() {
    _isLoading = true;
    notifyListeners();

    _scanHistory = _historyService.getScanHistory();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(ScanRecord record) async {
    await _historyService.saveScanRecord(record);
    loadHistory();
  }

  Future<void> deleteRecord(String id) async {
    await _historyService.deleteScanRecord(id);
    loadHistory();
  }

  Future<void> clearAllHistory() async {
    await _historyService.clearHistory();
    loadHistory();
  }
}
