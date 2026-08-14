import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';

class CropSelectionScreen extends StatelessWidget {
  const CropSelectionScreen({super.key});

  static const List<Map<String, dynamic>> cropsList = [
    {'name': 'Auto Detect', 'icon': Icons.brightness_auto, 'desc': 'AI determines the crop type'},
    {'name': 'Tomato', 'icon': Icons.album_rounded, 'desc': 'Lycopersicon esculentum'},
    {'name': 'Potato', 'icon': Icons.circle_rounded, 'desc': 'Solanum tuberosum'},
    {'name': 'Rice', 'icon': Icons.grain_rounded, 'desc': 'Oryza sativa'},
    {'name': 'Wheat', 'icon': Icons.grass_rounded, 'desc': 'Triticum aestivum'},
    {'name': 'Corn', 'icon': Icons.emoji_food_beverage_rounded, 'desc': 'Zea mays'},
    {'name': 'Cotton', 'icon': Icons.cloud_queue_sharp, 'desc': 'Gossypium'},
    {'name': 'Chili', 'icon': Icons.pest_control_rodent, 'desc': 'Capsicum annuum'},
    {'name': 'Apple', 'icon': Icons.apple_rounded, 'desc': 'Malus domestica'},
    {'name': 'Grapes', 'icon': Icons.blur_circular_rounded, 'desc': 'Vitis vinifera'},
  ];

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Crop Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Which crop leaf are you scanning?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecting a specific crop yields higher diagnostic accuracy.',
                style: TextStyle(color: theme.hintColor, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: cropsList.length,
                  itemBuilder: (context, index) {
                    final crop = cropsList[index];
                    final isAuto = crop['name'] == 'Auto Detect';
                    final isSelected = scanProvider.selectedCrop == crop['name'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: InkWell(
                        onTap: () {
                          scanProvider.selectCrop(crop['name']);
                          // Reset any old scans when selecting new crop
                          scanProvider.reset();
                          // Navigate to Scan tab
                          context.go('/?tab=1');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.08)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.12),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isAuto
                                      ? colorScheme.secondary.withOpacity(0.15)
                                      : colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    crop['icon'] as IconData,
                                    color: isAuto ? colorScheme.secondary : colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crop['name'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected ? colorScheme.primary : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        crop['desc'] as String,
                                        style: TextStyle(
                                          color: theme.hintColor,
                                          fontSize: 12,
                                          fontStyle: isAuto ? FontStyle.normal : FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: isSelected ? colorScheme.primary : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
