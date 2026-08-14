import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/scan_record.dart';
import '../../../core/services/prediction_service.dart';
import '../../history/providers/history_provider.dart';

class ScanProvider with ChangeNotifier {
  final DiseasePredictionService _predictionService;
  final ImagePicker _picker = ImagePicker();

  String _selectedCrop = 'Auto Detect';
  XFile? _pickedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;
  DiseasePredictionResult? _predictionResult;
  bool _isPestMode = false;
  bool _isWeedMode = false; // Mode Toggle: Weed Detection

  ScanProvider(this._predictionService);

  String get selectedCrop => _selectedCrop;
  XFile? get pickedImage => _pickedImage;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  DiseasePredictionResult? get predictionResult => _predictionResult;
  bool get isPestMode => _isPestMode;
  bool get isWeedMode => _isWeedMode;

  void selectCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void toggleScanMode(bool isPest) {
    _isPestMode = isPest;
    _isWeedMode = false;
    notifyListeners();
  }

  void toggleWeedMode(bool isWeed) {
    _isWeedMode = isWeed;
    _isPestMode = false;
    notifyListeners();
  }

  void reset() {
    _pickedImage = null;
    _predictionResult = null;
    _errorMessage = null;
    _isAnalyzing = false;
    notifyListeners();
  }

  Future<bool> pickImage(ImageSource source) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        _pickedImage = image;
        _predictionResult = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to capture or select image: ${e.toString()}';
      notifyListeners();
    }
    return false;
  }

  Future<void> analyzeImage(HistoryProvider historyProvider) async {
    if (_pickedImage == null) {
      _errorMessage = 'Please select or capture an image first.';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _errorMessage = null;
    _predictionResult = null;
    notifyListeners();

    try {
      final result = await _predictionService.predictCropDisease(
        imagePath: _pickedImage!.path,
        selectedCrop: _selectedCrop,
        isPestMode: _isPestMode,
        isWeedMode: _isWeedMode,
      );

      _predictionResult = result;

      // Save to history automatically
      final record = ScanRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: _pickedImage!.path,
        cropName: result.diseaseInfo.cropName,
        diseaseName: result.diseaseInfo.diseaseName,
        confidence: result.confidence,
        dateTime: DateTime.now(),
        diseaseInfoId: result.diseaseInfo.id,
      );

      await historyProvider.addRecord(record);
    } catch (e) {
      _errorMessage = 'Analysis failed: ${e.toString()}';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
