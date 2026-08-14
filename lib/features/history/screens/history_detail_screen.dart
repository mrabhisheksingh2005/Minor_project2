import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/disease_info.dart';
import '../../../core/models/scan_record.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScanRecord record;

  const HistoryDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Retrieve matching DiseaseInfo from dataset
    final diseaseInfo = DiseaseInfo.cropDiseasesDataset.firstWhere(
      (info) => info.id == record.diseaseInfoId,
      orElse: () => DiseaseInfo(
        id: 'fallback',
        cropName: record.cropName,
        diseaseName: record.diseaseName,
        description: 'Detailed report contents are stored locally. Follow general crop advisory.',
        symptoms: ['Slight leaf discolourations.', 'Structural leaf stress.'],
        causes: ['Soil nutrient disequilibrium or insect vector activity.'],
        treatment: ['Apply organic compost.', 'Observe watering cycles.'],
        prevention: ['Maintain sanitised field implements.', 'Aerate the cropping field.'],
      ),
    );

    final isHealthy = record.diseaseName.toLowerCase().contains('healthy');
    final statusColor = isHealthy ? Colors.green : Colors.red;
    final dateStr = DateFormat('MMMM dd, yyyy - hh:mm a').format(record.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Diagnosis Report'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image frame
            Container(
              height: 220,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(record.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        record.cropName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date card
                  Text(
                    'Scan captured on $dateStr',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // Title Card
                  Card(
                    elevation: 0,
                    color: statusColor.withOpacity(0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DIAGNOSED DISEASE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.diseaseName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      value: record.confidence,
                                      backgroundColor: Colors.grey.withOpacity(0.2),
                                      color: statusColor,
                                      strokeWidth: 5,
                                    ),
                                  ),
                                  Text(
                                    '${(record.confidence * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bullet sections
                  _buildCollapsibleSection(
                    context,
                    title: 'Description',
                    icon: Icons.info_outline,
                    content: Text(
                      diseaseInfo.description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),

                  _buildCollapsibleSection(
                    context,
                    title: 'Symptoms',
                    icon: Icons.biotech_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: diseaseInfo.symptoms
                          .map((s) => _buildBulletPoint(context, s))
                          .toList(),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),

                  _buildCollapsibleSection(
                    context,
                    title: 'Causes',
                    icon: Icons.science_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: diseaseInfo.causes
                          .map((c) => _buildBulletPoint(context, c))
                          .toList(),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),

                  _buildCollapsibleSection(
                    context,
                    title: 'Treatment & Remedies',
                    icon: Icons.healing_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: diseaseInfo.treatment
                          .map((t) => _buildBulletPoint(context, t, isTreatment: true))
                          .toList(),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),

                  _buildCollapsibleSection(
                    context,
                    title: 'Prevention Strategies',
                    icon: Icons.shield_outlined,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: diseaseInfo.prevention
                          .map((p) => _buildBulletPoint(context, p))
                          .toList(),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 8),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, {bool isTreatment = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isTreatment ? Icons.medical_services_outlined : Icons.circle,
            size: isTreatment ? 14 : 6,
            color: isTreatment ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
