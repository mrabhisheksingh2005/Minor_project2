import 'package:flutter/material.dart';
import '../../../core/models/disease_info.dart';

class CropDetailScreen extends StatelessWidget {
  final DiseaseInfo disease;

  const CropDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHealthy = disease.id.contains('healthy');
    final statusColor = isHealthy ? Colors.green : colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(disease.cropName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Icon Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.bug_report,
                    size: 64,
                    color: statusColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    disease.diseaseName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scientific Advisory Guide',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _buildAdvisorySection(
              context,
              title: 'Advisory Description',
              icon: Icons.info_outline,
              content: Text(
                disease.description,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Symptoms
            _buildAdvisorySection(
              context,
              title: 'Key Symptoms',
              icon: Icons.biotech,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.symptoms.map((s) => _buildBulletPoint(context, s)).toList(),
              ),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Causes
            _buildAdvisorySection(
              context,
              title: 'Primary Causes',
              icon: Icons.science_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.causes.map((c) => _buildBulletPoint(context, c)).toList(),
              ),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Treatment
            _buildAdvisorySection(
              context,
              title: 'Treatment & Remedies',
              icon: Icons.medical_services_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.treatment
                    .map((t) => _buildBulletPoint(context, t, isTreatment: true))
                    .toList(),
              ),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Prevention
            _buildAdvisorySection(
              context,
              title: 'Prevention Measures',
              icon: Icons.shield_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: disease.prevention.map((p) => _buildBulletPoint(context, p)).toList(),
              ),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorySection(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(height: 20),
            content,
          ],
        ),
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
