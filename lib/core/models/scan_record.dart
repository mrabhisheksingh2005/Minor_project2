import 'dart:convert';

class ScanRecord {
  final String id;
  final String imagePath;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final DateTime dateTime;
  final String? diseaseInfoId;

  const ScanRecord({
    required this.id,
    required this.imagePath,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.dateTime,
    this.diseaseInfoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'dateTime': dateTime.toIso8601String(),
      'diseaseInfoId': diseaseInfoId,
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String,
      cropName: map['cropName'] as String,
      diseaseName: map['diseaseName'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
      diseaseInfoId: map['diseaseInfoId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScanRecord.fromJson(String source) =>
      ScanRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}
