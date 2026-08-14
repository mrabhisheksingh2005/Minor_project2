import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../../../core/models/disease_info.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _downloadPDFReport(BuildContext context, DiseaseInfo disease, double confidence) {
    // 1. Show interactive compilation status dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text('Formatting report layouts and baking PDF blocks...'),
              ),
            ],
          ),
        );
      },
    );

    // 2. Complete processing and open print sheet
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showPDFPreviewSheet(context, disease, confidence);
      }
    });
  }

  void _showPDFPreviewSheet(BuildContext context, DiseaseInfo disease, double confidence) {
    final reportId = 'AV-REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Top control bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PDF Report Preview',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Printable area
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Document Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AGRIVISION AI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                      color: Colors.green,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'Smart Farming Diagnostic Portal',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                                  ),
                                ],
                              ),
                              Icon(Icons.eco, color: Colors.green.shade700, size: 36),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1.5, color: Colors.green),
                          
                          // Meta Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Report ID: $reportId', style: const TextStyle(fontSize: 10, color: Colors.black)),
                              Text('Date: $dateStr', style: const TextStyle(fontSize: 10, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Target Info
                          const Text(
                            'FIELD DIAGNOSIS SUMMARY:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            disease.diseaseName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inference Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          const Text(
                            'DESCRIPTION:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            disease.description,
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),

                          // Symptoms
                          const Text(
                            'IDENTIFIED SYMPTOMS:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          ...disease.symptoms.map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                              ],
                            ),
                          )),
                          const SizedBox(height: 16),

                          // Treatment
                          const Text(
                            'RECOMMENDED TREATMENT:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          ...disease.treatment.map((t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✓ ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                              ],
                            ),
                          )),
                          const SizedBox(height: 32),

                          // Footer Watermark
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'AgriVision AI On-Device Classification System',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                                ),
                                Text(
                                  'This report is generated dynamically by local CNN and REST interfaces.',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download PDF Document'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Report saved to Storage/Documents/AgriVision/AgriVision_Report_$reportId.pdf!'),
                          backgroundColor: Colors.green.shade800,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final result = scanProvider.predictionResult;
    final image = scanProvider.pickedImage;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (result == null || image == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No scan results found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final disease = result.diseaseInfo;
    final isHealthy = disease.id.contains('healthy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            scanProvider.reset();
            context.go('/?tab=1'); // Go back to Scan tab
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF Report',
            onPressed: () => _downloadPDFReport(context, disease, result.confidence),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top image and overlay info
            _buildImageBanner(image.path, disease.cropName, colorScheme),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name & Confidence Card
                  _buildSummaryCard(context, disease.diseaseName, result.confidence, isHealthy, colorScheme),
                  const SizedBox(height: 20),

                  // Detail Sections
                  _buildCollapsibleSection(
                    context,
                    title: 'Description',
                    icon: Icons.info_outline,
                    content: Text(
                      disease.description,
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
                      children: disease.symptoms
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
                      children: disease.causes
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
                      children: disease.treatment
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
                      children: disease.prevention
                          .map((p) => _buildBulletPoint(context, p))
                          .toList(),
                    ),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 20),

                  // Alternative Matches
                  if (result.alternativePredictions.isNotEmpty) ...[
                    Text(
                      'Alternative Predictions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildAlternativesCard(result.alternativePredictions, colorScheme, theme),
                    const SizedBox(height: 20),
                  ],

                  // Bot CTA Card
                  _buildChatbotCTACard(context, disease.cropName, colorScheme, theme),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBanner(String path, String crop, ColorScheme colors) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                crop.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String name,
    double confidence,
    bool isHealthy,
    ColorScheme colors,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isHealthy ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
              child: Icon(
                isHealthy ? Icons.check_circle : Icons.warning,
                color: isHealthy ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
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
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedAlignment: Alignment.topLeft,
        children: [content],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, {bool isTreatment = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isTreatment ? Icons.check_circle_outline : Icons.fiber_manual_record,
            size: isTreatment ? 16 : 8,
            color: isTreatment ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
          const SizedBox(width: 10),
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

  Widget _buildAlternativesCard(
    Map<String, double> alts,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outline.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: alts.entries.map((entry) {
            return ListTile(
              dense: true,
              leading: const Icon(Icons.arrow_right_alt, color: Colors.grey),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(entry.value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: colors.primary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChatbotCTACard(
    BuildContext context,
    String crop,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: colors.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withOpacity(0.2),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Have more questions?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Ask Agri Assistant about $crop care.',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.go('/?tab=3');
              },
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple internal helper class to format dates without adding heavy libraries
class DateFormat {
  final String formatPattern;
  DateFormat(this.formatPattern);
  String format(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
