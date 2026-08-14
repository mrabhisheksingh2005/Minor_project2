import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/disease_info.dart';

class CropGuideScreen extends StatefulWidget {
  const CropGuideScreen({super.key});

  @override
  State<CropGuideScreen> createState() => _CropGuideScreenState();
}

class _CropGuideScreenState extends State<CropGuideScreen> {
  String _selectedFilter = 'All';

  final List<String> _crops = [
    'All',
    'Tomato',
    'Potato',
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Chili',
    'Apple',
    'Grapes'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter the dataset based on selection
    final filteredDiseases = DiseaseInfo.cropDiseasesDataset.where((disease) {
      if (_selectedFilter == 'All') return true;
      return disease.cropName.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Crop Guide'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              itemCount: _crops.length,
              itemBuilder: (context, index) {
                final crop = _crops[index];
                final isSelected = _selectedFilter == crop;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(crop),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = crop;
                      });
                    },
                    selectedColor: colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                );
              },
            ),
          ),

          // Diseases List
          Expanded(
            child: filteredDiseases.isEmpty
                ? Center(
                    child: Text(
                      'No guide entries found.',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredDiseases.length,
                    itemBuilder: (context, index) {
                      final item = filteredDiseases[index];
                      final isHealthy = item.id.contains('healthy');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isHealthy
                                ? Colors.green.withOpacity(0.12)
                                : colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              isHealthy ? Icons.check_circle_outline : Icons.bug_report_outlined,
                              color: isHealthy ? Colors.green : colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            item.diseaseName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crop: ${item.cropName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            context.push('/crop-detail', extra: item);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
