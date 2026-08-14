import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../../history/providers/history_provider.dart';

class PestScannerScreen extends StatefulWidget {
  const PestScannerScreen({super.key});

  @override
  State<PestScannerScreen> createState() => _PestScannerScreenState();
}

class _PestScannerScreenState extends State<PestScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Force Pest Mode in provider when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).toggleScanMode(true);
      Provider.of<ScanProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Pest Detector'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Info Banner
              _buildInfoBanner(colorScheme, theme),
              const SizedBox(height: 16),

              // Image Frame (Crop selector removed)
              _buildImageFrame(context, scanProvider, colorScheme, theme),
              const SizedBox(height: 24),

              // Action Buttons
              if (scanProvider.pickedImage == null)
                _buildPickerButtons(context, scanProvider, colorScheme)
              else if (scanProvider.isAnalyzing)
                _buildAnalyzingState(context, colorScheme, theme)
              else
                _buildAnalysisButtons(context, scanProvider, historyProvider, colorScheme),

              const SizedBox(height: 24),
              // Tips for better pest identification
              _buildGuidanceCard(context, theme, colorScheme),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bug_report, color: Colors.amber.shade800, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Scanner: Pest & Insect Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Utilizing agrivision_pest_model.tflite',
                  style: TextStyle(color: theme.hintColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFrame(
    BuildContext context,
    ScanProvider provider,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final image = provider.pickedImage;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Image.file(
                File(image.path),
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.center_focus_strong,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Pest Image Captured',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Capture or pick a photo of the insect/damaged leaf',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPickerButtons(
    BuildContext context,
    ScanProvider provider,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => provider.pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => provider.pickImage(ImageSource.camera),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Executing TFLite Model Inference...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Running MobileNetV2 Pest classifier on device',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisButtons(
    BuildContext context,
    ScanProvider provider,
    HistoryProvider historyProvider,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        if (provider.errorMessage != null) ...[
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: provider.reset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bug_report),
                label: const Text('Detect Pest'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await provider.analyzeImage(historyProvider);
                  if (context.mounted && provider.predictionResult != null) {
                    context.go('/result');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuidanceCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Macro Photography Advisory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipRow(context, Icons.zoom_in, 'Focus directly on the insect body or chew markings.'),
            _buildTipRow(context, Icons.flash_on_outlined, 'Use flash inside thick tree canopies to highlight insect shell details.'),
            _buildTipRow(context, Icons.filter_center_focus, 'Align the leaf damage area in the center box of the camera.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
